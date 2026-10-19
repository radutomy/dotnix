switch:
    nh os switch . --bypass-root-check

cosmic:
    cosmic-ctl backup -x config /tmp/cosmic-backup.json
    jq -S '.operations |= sort_by(.component, .version)' /tmp/cosmic-backup.json > cosmic/$(hostname).json

update:
    nix flake update
    just switch
    -git commit -m 'flake.lock' -- flake.lock && git push

charging_profile := "/sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile"

# nixqs: charge to 100% (until next boot)
battery-full:
    echo high_capacity | sudo tee {{ charging_profile }}

# nixqs: cap charging at ~80%
battery-saver:
    echo stationary | sudo tee {{ charging_profile }}

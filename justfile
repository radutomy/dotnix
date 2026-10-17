switch:
    nh os switch . --bypass-root-check

cosmic:
    cosmic-ctl backup -x config /tmp/cosmic-backup.json
    jq -S '.operations |= sort_by(.component, .version)' /tmp/cosmic-backup.json > cosmic/$(hostname).json

update:
    nix flake update
    nh os switch . --bypass-root-check
    -git commit -m 'flake.lock' -- flake.lock && git push

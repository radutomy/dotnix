switch_command := if os() == "macos" {
    "sudo darwin-rebuild switch --flake .#darwin"
} else if path_exists("/etc/NIXOS") == "true" {
    "nh os switch . --bypass-root-check"
} else {
    "nh home switch ."
}

switch:
    {{ switch_command }}

cosmic:
    cosmic-ctl backup -x config /tmp/cosmic-backup.json
    jq -S '.operations |= sort_by(.component, .version)' /tmp/cosmic-backup.json > cosmic/config.json

update:
    nix flake update
    {{ switch_command }}
    -git commit -m 'flake.lock' -- flake.lock && git push

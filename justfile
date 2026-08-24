platform := if os() == "macos" { "darwin" } else if path_exists("/etc/NIXOS") == "true" { "nixos" } else { "home" }

darwin_switch := "sudo darwin-rebuild switch --flake .#darwin"
nixos_switch := "nh os switch . --bypass-root-check"
home_switch := "nh home switch ."

switch_command := if platform == "darwin" { darwin_switch } else if platform == "nixos" { nixos_switch } else { home_switch }

switch:
    {{ switch_command }}

cosmic:
    cosmic-ctl backup -x config /tmp/cosmic-backup.json
    jq -S '.operations |= sort_by(.component, .version)' /tmp/cosmic-backup.json > cosmic/config.json

update:
    nix flake update
    {{ switch_command }}
    git commit -m 'flake.lock' -- flake.lock
    git push

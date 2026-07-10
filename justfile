switch_command := if path_exists("/etc/NIXOS") == "true" { "nh os switch . --bypass-root-check" } else { "nh home switch ." }

switch:
    {{ switch_command }}

update:
    {{ switch_command }} --update
    git commit -m 'flake.lock' -- flake.lock
    git push

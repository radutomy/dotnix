switch:
    nh os switch . --bypass-root-check --no-rom --no-build-output

cosmic:
    cosmic-ctl backup -x config /tmp/cosmic-backup.json
    jq -S '.operations |= (map(select(.component != "dev.edfloreshz.Calculator")) | sort_by(.component, .version))' /tmp/cosmic-backup.json > cosmic/$(hostname).json

update:
    nix flake update
    just switch
    -git commit -m 'flake.lock' -- flake.lock && git push

codex-push:
    ./scripts/codex-context.sh push

codex-pull:
    ./scripts/codex-context.sh pull

claude-push:
    ./scripts/claude-context.sh push

claude-pull:
    ./scripts/claude-context.sh pull

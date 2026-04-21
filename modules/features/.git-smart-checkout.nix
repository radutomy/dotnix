_: {
  flake.nixosModules.git-smart-checkout =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "lazygit-smart-checkout" ''
          #!/usr/bin/env bash
          set -euo pipefail

          matching_branch_stashes() {
            git stash list --format='%gd%x09%gs' |
              awk -F $'\t' -v branch="$1" '$2 == "On " branch ": smart-checkout::" branch { print $1 }'
          }

          find_branch_stash() {
            matching_branch_stashes "$1" | sed -n '1p'
          }

          branch_upstream() {
            git for-each-ref --format='%(upstream:short)' "refs/heads/$1" | sed -n '1p'
          }

          drop_older_branch_stashes() {
            local refs_count i
            local -a refs

            mapfile -t refs < <(matching_branch_stashes "$1")

            refs_count="''${#refs[@]}"
            (( refs_count <= 1 )) && return 0

            for (( i = refs_count - 1; i >= 1; i-- )); do
              git stash drop "''${refs[$i]}" >/dev/null
            done
          }

          stash_current_branch() {
            local current
            current="$(git branch --show-current)"

            [[ -n "$current" ]] || {
              echo "Not on a local branch." >&2
              exit 1
            }

            if [[ -n "$(git status --porcelain)" ]]; then
              git stash push -u -m "smart-checkout::''${current}" >/dev/null
              drop_older_branch_stashes "$current"
            fi
          }

          restore_branch_stash() {
            local branch stash_ref

            branch="$1"
            drop_older_branch_stashes "$branch"
            stash_ref="$(find_branch_stash "$branch" || true)"
            if [[ -n "''${stash_ref:-}" ]]; then
              if git stash apply --index "$stash_ref" >/dev/null; then
                git stash drop "$stash_ref" >/dev/null
              else
                git reset --hard -q HEAD >/dev/null
                git clean -fd -q >/dev/null
                echo "Warning: could not restore saved changes for $branch from $stash_ref." >&2
                echo "You are now on $branch, but the saved changes were left in the stash." >&2
                echo "Reapply manually with: git stash apply --index $stash_ref" >&2
              fi
            fi
          }

          restore_current_branch_after_failed_switch() {
            local branch stash_ref

            branch="$1"
            stash_ref="$(find_branch_stash "$branch" || true)"
            [[ -n "''${stash_ref:-}" ]] || return 0

            if git stash apply --index "$stash_ref" >/dev/null; then
              git stash drop "$stash_ref" >/dev/null
            else
              echo "Failed to restore saved changes for $branch after checkout failed." >&2
              echo "Your saved changes are still in $stash_ref." >&2
              exit 1
            fi
          }

          smart_switch_local() {
            local current target

            target="$1"
            current="$(git branch --show-current)"

            [[ -n "$current" ]] || {
              echo "Not on a local branch." >&2
              exit 1
            }

            [[ "$target" == "$current" ]] && exit 0

            stash_current_branch
            if ! git switch "$target" >/dev/null; then
              restore_current_branch_after_failed_switch "$current"
              exit 1
            fi
            restore_branch_stash "$target"
          }

          smart_switch_remote() {
            local remote target_branch current upstream target_upstream

            remote="$1"
            target_branch="$2"
            current="$(git branch --show-current)"

            [[ -n "$current" ]] || {
              echo "Not on a local branch." >&2
              exit 1
            }

            upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
            if [[ "$current" == "$target_branch" && "$upstream" == "$remote/$target_branch" ]]; then
              exit 0
            fi

            if git show-ref --verify --quiet "refs/heads/$target_branch"; then
              target_upstream="$(branch_upstream "$target_branch")"
              if [[ -n "$target_upstream" && "$target_upstream" != "$remote/$target_branch" ]]; then
                echo "Local branch $target_branch tracks $target_upstream, not $remote/$target_branch." >&2
                exit 1
              fi
            fi

            stash_current_branch

            if git show-ref --verify --quiet "refs/heads/$target_branch"; then
              if ! git switch "$target_branch" >/dev/null; then
                restore_current_branch_after_failed_switch "$current"
                exit 1
              fi
              if [[ -z "''${target_upstream:-}" ]]; then
                git branch --set-upstream-to "$remote/$target_branch" "$target_branch" >/dev/null
              fi
            else
              if ! git switch --track -c "$target_branch" "$remote/$target_branch" >/dev/null; then
                restore_current_branch_after_failed_switch "$current"
                exit 1
              fi
            fi

            restore_branch_stash "$target_branch"
          }

          mode="''${1:?mode required}"
          case "$mode" in
            local)
              smart_switch_local "''${2:?target branch required}"
              ;;
            remote)
              smart_switch_remote "''${2:?remote name required}" "''${3:?remote branch required}"
              ;;
            *)
              echo "Unknown mode: $mode" >&2
              exit 1
              ;;
          esac
        '')
      ];

      programs.lazygit.settings.customCommands = [
        {
          key = "<space>";
          context = "localBranches";
          description = "Smart checkout";
          loadingText = "Smart checkout...";
          command = "lazygit-smart-checkout local \"{{.SelectedLocalBranch.Name}}\"";
        }
        {
          key = "<space>";
          context = "remoteBranches";
          description = "Smart checkout";
          loadingText = "Smart checkout...";
          command = "lazygit-smart-checkout remote \"{{.SelectedRemoteBranch.RemoteName}}\" \"{{.SelectedRemoteBranch.Name}}\"";
        }
      ];
    };
}

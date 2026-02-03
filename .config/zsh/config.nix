{ pkgs, lib, config, ... }:
{
  programs.lsd = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      ls = lib.mkForce "lsd --group-dirs=first";
      ll = lib.mkForce "lsd -lah --group-dirs=first";
      l = lib.mkForce "lsd -A --group-dirs=first";
      lr = "lsd --tree --group-dirs=first";
      lt = "lsd --tree --group-dirs=first";
      cat = "bat --style=plain";
      vim = "nvim";
      c = "clear";
      p = "python";
      gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux";
      pi1 = "ssh pi1";
      pi2 = "ssh pi2";
      nas = "ssh nas";
    };

    initContent = ''
      # PATH
      path+=("$HOME/.cargo/bin" "$HOME/.local/bin" "$PNPM_HOME")
      export PATH
      export GPG_TTY=$(tty)
      export PNPM_HOME="/root/.local/share/pnpm"

      # Prompt: ~/path branch >
      setopt PROMPT_SUBST
      _git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
        branch=$(git describe --tags --exact-match HEAD 2>/dev/null) || \
        branch=$(git rev-parse --short HEAD 2>/dev/null | sed 's/^/@/')
        [[ -n "$branch" ]] && echo "$branch "
      }
      PROMPT='%F{cyan}%~%f %F{magenta}$(_git_branch)%f%F{cyan}>%f '

      # cd uses zoxide
      alias cd='z'

      # Tab completion: triggers fzf picker for z/cd when multiple zoxide matches
      _zoxide_tab_complete() {
        local tokens=(''${(z)BUFFER})
        local cmd="''${tokens[1]}"
        local arg="''${tokens[2]}"

        if [[ ("$cmd" == "z" || "$cmd" == "cd") && -n "$arg" ]]; then
          # Check for local directory first
          local -a local_dirs
          local_dirs=( ''${arg}*(/N) )

          if (( ''${#local_dirs[@]} > 0 )); then
            # Local dirs exist, use normal completion
            zle expand-or-complete
          else
            # Query zoxide
            local -a matches
            matches=("''${(@f)$(zoxide query -l -- "$arg" 2>/dev/null)}")

            if (( ''${#matches[@]} > 1 )); then
              # Multiple matches - show fzf
              local result
              result=$(printf '%s\n' "''${matches[@]}" | fzf --height=40% --reverse --prompt="$arg > ")
              if [[ -n "$result" ]]; then
                BUFFER="$cmd $result"
                CURSOR=''${#BUFFER}
              fi
              zle redisplay
            elif (( ''${#matches[@]} == 1 )); then
              # Single match - complete it
              BUFFER="$cmd ''${matches[1]}"
              CURSOR=''${#BUFFER}
              zle redisplay
            else
              zle expand-or-complete
            fi
          fi
        else
          zle expand-or-complete
        fi
      }
      zle -N _zoxide_tab_complete
      bindkey '^I' _zoxide_tab_complete

      # Auto lsd after cd
      _lsd_after_cd() { lsd -F }
      chpwd_functions+=(_lsd_after_cd)

      # Ctrl+F: zoxide fzf picker
      _zoxide_pick() {
        local result
        result=$(zoxide query -i 2>/dev/null)
        if [[ -n "$result" ]]; then
          BUFFER="cd $result"
          CURSOR=$#BUFFER
          zle accept-line
        fi
        zle reset-prompt
      }
      zle -N _zoxide_pick
      bindkey '^F' _zoxide_pick

      # Key bindings
      bindkey '^E' clear-screen

      # Tab completion menu (navigate with Tab/Shift+Tab, select with Enter)
      zmodload zsh/complist
      zstyle ':completion:*' menu select
      bindkey -M menuselect '\t' menu-complete
      bindkey -M menuselect '\e[Z' reverse-menu-complete
    '';
  };
}

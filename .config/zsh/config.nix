{ pkgs, lib, config, ... }:
{
  programs.lsd = {
    enable = true;
    enableZshIntegration = false; # We define our own aliases
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
      # lsd aliases (use mkForce to override lsd module defaults)
      ls = lib.mkForce "lsd --group-dirs=first";
      ll = lib.mkForce "lsd -lah --group-dirs=first";
      l = lib.mkForce "lsd -A --group-dirs=first";
      lr = "lsd --tree --group-dirs=first";
      lx = "lsd -X --group-dirs=first";
      lt = "lsd --tree --group-dirs=first";

      # Other aliases
      cat = "bat --style=plain";
      vim = "nvim";
      c = "clear";
      p = "python";
      gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux";

      # SSH
      pi1 = "ssh pi1";
      pi2 = "ssh pi2";
      nas = "ssh nas";
    };

    initContent = ''
      # --- PATH ---
      path+=("$HOME/.cargo/bin" "$HOME/.local/bin" "$PNPM_HOME")
      export PATH

      # --- Environment ---
      export GPG_TTY=$(tty)
      export PNPM_HOME="/root/.local/share/pnpm"

      # --- Prompt (single line: ~/path branch > ) ---
      setopt PROMPT_SUBST

      # Git branch for prompt
      _git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
        branch=$(git describe --tags --exact-match HEAD 2>/dev/null) || \
        branch=$(git rev-parse --short HEAD 2>/dev/null | sed 's/^/@/')
        [[ -n "$branch" ]] && echo "$branch "
      }

      # Colors: cyan for path, magenta for git
      # %~ = path with ~ for home (full path, no abbreviation)
      PROMPT='%F{cyan}%~%f %F{magenta}$(_git_branch)%f%F{cyan}>%f '

      # Use zoxide's z command as cd (zoxide init zsh already provides z and zi)
      alias cd='z'

      # Fish-like completion for cd/z: local dirs first, then zoxide database
      _cd_zoxide_complete() {
        [[ ''${#words[@]} -eq $CURRENT ]] || return 0

        if [[ ''${#words[@]} -eq 2 ]]; then
          local query="''${words[2]}"
          # Check if any local directories match
          local has_local
          has_local=$(print -l ''${query}*(-/DN) 2>/dev/null | head -1)

          if [[ -n "$has_local" ]]; then
            # Local matches found
            _path_files -/
          else
            # No local matches - query zoxide database
            local zoxide_out
            zoxide_out=$(zoxide query -l -- "$query" 2>/dev/null)
            if [[ -n "$zoxide_out" ]]; then
              local IFS=$'\n'
              compadd -U -Q -- $zoxide_out
            fi
          fi
        fi
      }
      compdef _cd_zoxide_complete cd z

      # --- Auto lsd after cd ---
      _lsd_after_cd() {
        lsd -F
      }
      chpwd_functions+=(_lsd_after_cd)

      # --- Tab completion: directories alongside commands ---
      # Enable completion system
      autoload -Uz compinit && compinit

      # Show files/dirs when completing commands (fish-like behavior)
      setopt COMPLETE_IN_WORD
      setopt AUTO_MENU
      setopt AUTO_LIST
      zstyle ':completion:*' completer _complete _files
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # --- Key bindings ---
      bindkey '^E' clear-screen  # Ctrl+E to clear
      bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

      # --- fzf configuration ---
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git --exclude node_modules --exclude .cache"
    '';
  };
}

{ pkgs, lib, config, ... }:
{
  programs.lsd = {
    enable = true;
    enableZshIntegration = false; # We define our own aliases
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # We wrap it ourselves for fish-like behavior
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

      # --- Zoxide with fish-like cd behavior ---
      # cd: no args=home, -=previous, dir=direct, else=zoxide query
      cd() {
        if [[ $# -eq 0 ]]; then
          builtin cd "$HOME"
        elif [[ "$1" == "-" ]]; then
          builtin cd -
        elif [[ -d "$1" ]]; then
          builtin cd "$1"
        else
          local result
          result=$(zoxide query -- "$@") && builtin cd "$result"
        fi
      }

      # Hook to add directories to zoxide database
      _zoxide_hook() {
        zoxide add -- "$PWD"
      }
      chpwd_functions+=(_zoxide_hook)

      # Interactive zoxide
      zi() {
        local result
        result=$(zoxide query -i -- "$@") && builtin cd "$result"
      }

      # Zoxide completion for cd - fish-like behavior
      _zoxide_z_complete() {
        # Only complete at end of line
        [[ ''${#words[@]} -eq $CURRENT ]] || return

        if [[ ''${#words[@]} -eq 2 ]]; then
          # First argument: try directories first
          _cd -/
          # If no local matches, query zoxide
          if [[ ''${compstate[nmatches]} -eq 0 ]]; then
            local zoxide_out
            zoxide_out=$(zoxide query -l -- "''${words[2]}" 2>/dev/null)
            [[ -n "$zoxide_out" ]] && compadd -U -Q -- ''${(f)zoxide_out}
          fi
        else
          # Multiple arguments: query zoxide with all args
          local zoxide_out
          zoxide_out=$(zoxide query -l -- ''${words[2,-1]} 2>/dev/null)
          [[ -n "$zoxide_out" ]] && compadd -U -Q -- ''${(f)zoxide_out}
        fi
      }
      compdef _zoxide_z_complete cd

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

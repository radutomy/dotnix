{ pkgs, lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      path = "${config.xdg.configHome}/zsh/.zsh_history";
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      # SSH
      pi1 = "ssh pi1";
      pi2 = "ssh pi2";
      nas = "ssh nas";

      # lsd (override lsd module defaults)
      ls = lib.mkForce "lsd --group-dirs=first";
      ll = lib.mkForce "lsd -lah --group-dirs=first";
      l = lib.mkForce "lsd -A --group-dirs=first";
      lr = "lsd --tree --group-dirs=first";
      lx = "lsd -X --group-dirs=first";
      lt = "lsd --tree --group-dirs=first";

      # Random
      cat = "bat --style=plain";
      vim = "nvim";
      c = "clear";
      p = "python";
      gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux";
    };

    sessionVariables = {
      EDITOR = "nvim";
      GPG_TTY = "$(tty)";
      PNPM_HOME = "$HOME/.local/share/pnpm";
    };

    initContent = ''
      # Completion: show directories alongside commands (like fish)
      setopt AUTO_CD              # cd into directory by typing its name
      setopt COMPLETE_IN_WORD     # complete from both ends

      # Show files/directories in command position (like fish)
      zstyle ':completion:*' completer _complete _ignored _files
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive
      zstyle ':completion:*:-command-:*' tag-order 'commands executables files directories'
      zstyle ':completion:*' file-patterns '*:all-files'

      # PATH
      path+=("$HOME/.cargo/bin" "$HOME/.local/bin" "$PNPM_HOME")
      export PATH

      # fzf exclusions (matching fish config)
      FZF_EXCLUDES="--exclude node_modules \
        --exclude .git \
        --exclude .cache \
        --exclude .npm \
        --exclude .cargo \
        --exclude .rustup \
        --exclude .gradle \
        --exclude .dotnet \
        --exclude .vscode-server \
        --exclude .vscode-remote-containers \
        --exclude .gnupg \
        --exclude .launchpadlib \
        --exclude .claude \
        --exclude .gemini \
        --exclude .local/share \
        --exclude .local/state \
        --exclude dist \
        --exclude build \
        --exclude target \
        --exclude venv \
        --exclude __pycache__"

      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
      export FZF_DEFAULT_COMMAND="fd --hidden --max-depth 5 $FZF_EXCLUDES"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # CTRL+F to search files and open in editor on Enter (like fish)
      fzf-file-widget-custom() {
        local file=$(eval "$FZF_DEFAULT_COMMAND" | fzf --bind "enter:become($EDITOR {})")
        zle redisplay
      }
      zle -N fzf-file-widget-custom
      bindkey '^F' fzf-file-widget-custom

      # CTRL+E to clear screen
      bindkey '^E' clear-screen

      # cd replacement with zoxide (matching fish behavior)
      cd() {
        if [[ $# -eq 0 ]]; then
          builtin cd ~
        elif [[ "$1" == "-" ]]; then
          builtin cd -
        elif [[ -d "$1" ]]; then
          builtin cd "$1"
        else
          local result=$(zoxide query -- "$@")
          if [[ -n "$result" ]]; then
            builtin cd "$result"
          else
            echo "zoxide: no match found" >&2
            return 1
          fi
        fi
      }

      # Tab completion: directories first, then zoxide results
      _cd_zoxide_complete() {
        local dirs=(''${(f)"$(fd --type d --max-depth 1 2>/dev/null)"})
        if [[ ''${#dirs[@]} -gt 0 ]]; then
          _describe 'directories' dirs
        fi
        local zoxide_results=(''${(f)"$(zoxide query -l ''${words[2]} 2>/dev/null)"})
        if [[ ''${#zoxide_results[@]} -gt 0 ]]; then
          _describe 'zoxide' zoxide_results
        fi
      }
      compdef _cd_zoxide_complete cd

      # Auto ls after cd
      chpwd() {
        lsd -F
      }

      # Prompt (hydro style: path + git branch + > on same line)
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats ' %F{yellow}%b%f'
      setopt PROMPT_SUBST
      PROMPT='%F{green}%~%f''${vcs_info_msg_0_} %F{green}>%f '
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.lsd = {
    enable = true;
    enableZshIntegration = false;  # We define our own aliases
  };

  programs.bat.enable = true;
}

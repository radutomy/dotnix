{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      path = "$HOME/.config/zsh/.zsh_history";
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      # SSH
      pi1 = "ssh pi1";
      pi2 = "ssh pi2";
      nas = "ssh nas";

      # lsd
      ls = "lsd --group-dirs=first";
      ll = "lsd -lah --group-dirs=first";
      l = "lsd -A --group-dirs=first";
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

    initExtra = ''
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

      # cd replacement with zoxide
      alias cd="z"

      # Auto ls after cd
      chpwd() {
        lsd -F
      }

      # Prompt (hydro style: path + git branch on first line, > on second)
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats ' %F{yellow}%b%f'
      setopt PROMPT_SUBST
      PROMPT='%F{green}%~%f''${vcs_info_msg_0_}
%F{green}>%f '
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

  programs.lsd.enable = true;
  programs.bat.enable = true;
}

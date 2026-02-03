{ pkgs, lib, config, ... }:
{
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
  ];

  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

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

    shellAliases = {
      cd = "z";
      ls = lib.mkForce "lsd --group-dirs=first";
      ll = lib.mkForce "lsd -lah --group-dirs=first";
      l = lib.mkForce "lsd -A --group-dirs=first";
      cat = "bat --style=plain";
      vim = "nvim";
      c = "clear";
      p = "python";
      gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux";
	  np = "ssh naspi"
      nas = "ssh nas";
    };

    initContent = ''
      export GPG_TTY=$(tty)

      # Prompt
      setopt PROMPT_SUBST
      _git_branch() {
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
        branch=$(git describe --tags --exact-match HEAD 2>/dev/null) || \
        branch=$(git rev-parse --short HEAD 2>/dev/null | sed 's/^/@/')
        [[ -n "$branch" ]] && echo "$branch "
      }
      PROMPT='%F{green}%~%f %F{magenta}$(_git_branch)%f%F{white}❱%f '

      # Tab: fzf picker for z/cd with zoxide
      _ztab() {
        local -a t=(''${(z)BUFFER})
        local cmd=''${t[1]} arg=''${t[2]}
        [[ $cmd != (z|cd) || -z $arg ]] && { zle expand-or-complete; return }
        local -a d=(''${arg}*(/N))
        (( ''${#d[@]} )) && { zle expand-or-complete; return }
        local -a m=("''${(@f)$(zoxide query -l -- $arg 2>/dev/null)}")
        case ''${#m[@]} in
          0) zle expand-or-complete ;;
          1) BUFFER="$cmd ''${m[1]}"; CURSOR=''${#BUFFER}; zle redisplay ;;
          *) local r=$(printf '%s\n' "''${m[@]}" | fzf --height=40% --reverse --cycle --bind 'tab:down,btab:up')
             [[ -n $r ]] && BUFFER="$cmd $r" && CURSOR=''${#BUFFER}; zle redisplay ;;
        esac
      }
      zle -N _ztab
      bindkey '^I' _ztab

      chpwd() { lsd -F }

      # Ctrl+E clear screen
      bindkey '^E' clear-screen
    '';
  };
}

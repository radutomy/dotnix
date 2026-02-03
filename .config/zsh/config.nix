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

      # Tab: fzf picker for z/cd, normal completion otherwise
      _z_tab() {
        local cmd=''${(z)BUFFER}
        local arg=''${cmd[2]}
        [[ ''${cmd[1]} != (z|cd) || -z $arg ]] && { zle expand-or-complete; return }
        [[ -n ''${arg}*(/N[1]) ]] && { zle expand-or-complete; return }
        local matches=(''${(f)"$(zoxide query -l -- $arg 2>/dev/null)"})
        (( ! ''${#matches} )) && { zle expand-or-complete; return }
        (( ''${#matches} == 1 )) && { BUFFER="''${cmd[1]} ''${matches[1]}"; CURSOR=''${#BUFFER}; zle redisplay; return }
        local pick=$(printf '%s\n' "''${matches[@]}" | fzf --height=40% --reverse --cycle --bind 'tab:down,btab:up')
        [[ -n $pick ]] && BUFFER="''${cmd[1]} $pick" && CURSOR=''${#BUFFER}
        zle redisplay
      }
      zle -N _z_tab && bindkey '^I' _z_tab

      # Auto lsd after cd
      chpwd_functions+=( lsd\ -F )

      # Ctrl+E clear, Ctrl+F zoxide picker
      bindkey '^E' clear-screen
      _zf() { local r=$(zoxide query -i 2>/dev/null); [[ -n $r ]] && BUFFER="cd $r" && zle accept-line; zle reset-prompt }
      zle -N _zf && bindkey '^F' _zf
    '';
  };
}

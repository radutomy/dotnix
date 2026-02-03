{ pkgs, lib, config, ... }:

let
  prompt = ''
    setopt PROMPT_SUBST
    _git_branch() {
      local branch
      branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
      branch=$(git describe --tags --exact-match HEAD 2>/dev/null) || \
      branch=$(git rev-parse --short HEAD 2>/dev/null | sed 's/^/@/')
      [[ -n "$branch" ]] && echo "$branch "
    }
    PROMPT='%F{green}%~%f %F{magenta}$(_git_branch)%f%F{white}❱%f '
  '';

  # Zoxide fallback when no local dirs match (fzf-tab handles the rest)
  zoxideFallback = ''
    _zf() {
      local -a t=(''${(z)BUFFER}) d
      local c=''${t[1]} a=''${t[2]} r
      if [[ $c == (z|cd) && -n $a ]]; then
        d=(''${a}*(/N))
        if (( ! ''${#d} )); then
          r=$(zoxide query -l -- $a 2>/dev/null | fzf --height=40% --reverse --cycle --bind 'tab:down,btab:up')
          [[ -n $r ]] && BUFFER="$c $r" && CURSOR=''${#BUFFER} && zle redisplay && return
        fi
      fi
      zle fzf-tab-complete
    }
    zle -N _zf && bindkey '^I' _zf
  '';

  hooks = "chpwd() { lsd -F }";
  keybindings = "bindkey '^E' clear-screen";

in
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
      ls = "lsd --group-dirs=first";
      ll = "lsd -lah --group-dirs=first";
      l = "lsd -A --group-dirs=first";
      cat = "bat --style=plain";
      vim = "nvim";
      c = "clear";
      p = "python";
      gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux";
	  np = "ssh naspi";
      nas = "ssh nas";
    };

    plugins = [{
      name = "fzf-tab";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
    }];

    initContent = ''
      export GPG_TTY=$(tty)
      ${prompt}
      ${zoxideFallback}
      ${hooks}
      ${keybindings}
    '';
  };
}

{ pkgs, lib, config, ... }:

let
  prompt = ''
    setopt PROMPT_SUBST
    _gb() { local b=$(git symbolic-ref --short HEAD || git describe --tags --exact-match || git rev-parse --short HEAD | sed 's/^/@/') 2>/dev/null; [[ -n $b ]] && echo "$b " }
    PROMPT='%F{green}%~%f %F{magenta}$(_gb)%f%F{white}❱%f '
  '';

  zoxideTab = ''
    _ztab() {
      local -a t=(''${(z)BUFFER}) d; local c=''${t[1]} a=''${t[2]} r
      [[ $c != (z|cd) || -z $a ]] && { zle expand-or-complete; return }
      d=(''${a}*(/N)); (( ''${#d} == 1 )) && d=(''${d[1]}/*(/N))
      (( ! ''${#d} )) && d=("''${(@f)$(zoxide query -l -- $a 2>/dev/null)}")
      case ''${#d} in
        0) zle expand-or-complete; return ;;
        1) BUFFER="$c ''${d[1]}" ;;
        *) r=$(printf '%s\n' "''${d[@]}" | fzf --height=40% --reverse --cycle --bind 'tab:down,btab:up'); [[ -n $r ]] && BUFFER="$c $r" ;;
      esac
      CURSOR=''${#BUFFER}; zle redisplay
    }
    zle -N _ztab && bindkey '^I' _ztab
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

    initContent = ''
      export GPG_TTY=$(tty)
      ${prompt}
      ${zoxideTab}
      ${hooks}
      ${keybindings}
    '';
  };
}

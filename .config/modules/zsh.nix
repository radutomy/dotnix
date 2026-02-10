{ pkgs, config, ... }:
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

  zoxideFallback = ''
    zstyle ':fzf-tab:complete:(cd|z):*' disabled-on any
    zstyle ':completion:*:(cd|z):*' menu select
    zstyle ':completion:*' matcher-list "m:{a-z}={A-Z}"

    typeset -ga _zr=(); typeset -gi _zi=0
    _zf() {
      local cmd=''${''${(z)BUFFER}[1]} arg=''${''${(z)BUFFER}[2]}
      if [[ $cmd != (z|cd) || -z $arg ]]; then _zr=(); _zi=0; zle fzf-tab-complete; return; fi
      # cycle through existing zoxide results
      if (( ''${#_zr} > 1 && _zi > 0 )) && [[ $arg == ''${_zr[$_zi]} ]]; then
        _zi=$(( _zi % ''${#_zr} + 1 ))
        BUFFER="$cmd ''${_zr[$_zi]}"; CURSOR=''${#BUFFER}; zle autosuggest-clear; zle redisplay; return
      fi
      _zr=(); _zi=0
      # local dirs match? use normal completion
      local -a _ld=(''${arg}*(/N))
      (( ''${#_ld} )) && { zle fzf-tab-complete; return; }
      # fall back to zoxide
      _zr=("''${(@f)$(zoxide query -l -- $arg 2>/dev/null)}"); _zi=1
      [[ -n ''${_zr[1]} ]] && { BUFFER="$cmd ''${_zr[1]}"; CURSOR=''${#BUFFER}; zle autosuggest-clear; zle redisplay; return; }
      _zr=(); _zi=0; zle fzf-tab-complete
    }
    zle -N _zf && bindkey '^I' _zf
  '';
in
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
    historySubstringSearch.enable = true;
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
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
    initContent = ''
      ${prompt}
      ${zoxideFallback}
      chpwd() { lsd -F }
      bindkey '^E' clear-screen
    '';
  };
}

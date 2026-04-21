_: {
  flake.nixosModules.zsh =
    { pkgs, ... }:
    let
      prompt = ''
        setopt PROMPT_SUBST
        PROMPT='%F{green}%~%f ''${''${GITSTATUS_PROMPT:+''${GITSTATUS_PROMPT//\%76F/%244F} }}%F{white}❱%f '
      '';

      zoxideFallback = ''
        zstyle ':fzf-tab:complete:(cd|z):*' disabled-on any
        zstyle ':completion:*:(cd|z):*' menu select
        zstyle ':completion:*' matcher-list "m:{a-z}={A-Z}"

        typeset -ga _zr=(); typeset -gi _zi=0
        _zf() {
          local cmd=''${''${(z)BUFFER}[1]} arg=''${''${(z)BUFFER}[2]}
          if [[ $cmd != (z|cd) || -z $arg ]]; then _zr=(); _zi=0; zle fzf-tab-complete; return; fi
          if (( ''${#_zr} > 1 && _zi > 0 )) && [[ $arg == ''${_zr[$_zi]} ]]; then
            _zi=$(( _zi % ''${#_zr} + 1 ))
            BUFFER="$cmd ''${_zr[$_zi]}"; CURSOR=''${#BUFFER}; zle autosuggest-clear; zle redisplay; return
          fi
          _zr=(); _zi=0
          local -a _ld=(''${arg}*(/N))
          (( ''${#_ld} )) && { zle fzf-tab-complete; return; }
          _zr=("''${(@f)$(zoxide query -l -- $arg 2>/dev/null)}"); _zi=1
          [[ -n ''${_zr[1]} ]] && { BUFFER="$cmd ''${_zr[1]}"; CURSOR=''${#BUFFER}; zle autosuggest-clear; zle redisplay; return; }
          _zr=(); _zi=0; zle fzf-tab-complete
        }
        zle -N _zf && bindkey '^I' _zf
      '';
    in
    {
      environment.systemPackages = with pkgs; [ lsd zoxide ];

      programs.fzf = {
        fuzzyCompletion = true;
        keybindings = true;
      };

      programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          cd = "z";
        };
        interactiveShellInit = ''
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
            source ${pkgs.gitstatus}/share/gitstatus/gitstatus.prompt.zsh
            source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
            bindkey -e
            eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
            ${prompt}
            ${zoxideFallback}
            chpwd() { lsd -F }
            precmd() { print -Pn "\e]2;%~  ''${HOST_ICON:+''${HOST_ICON} }%m\a" }
            bindkey '^E' clear-screen
            bindkey "''${terminfo[kRIT5]}" forward-word
            bindkey "''${terminfo[kLFT5]}" backward-word
            bindkey "''${terminfo[kcuu1]}" history-substring-search-up
            bindkey "''${terminfo[kcud1]}" history-substring-search-down
          '';
      };
    };
}

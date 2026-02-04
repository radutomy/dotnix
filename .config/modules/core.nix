# Core module - everyone gets this
{ pkgs, pkgs-unstable, config, ... }:
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
    _zf() {
      local -a t=(''${(z)BUFFER}) d; local c=''${t[1]} a=''${t[2]} r
      d=(''${a}*(/N))
      if [[ $c == (z|cd) && -n $a && ''${#d} -eq 0 ]]; then
        r=$(zoxide query -l -- $a 2>/dev/null | fzf --height=40% --reverse --cycle --bind 'tab:down,btab:up' --color=pointer:#C44300)
        [[ -n $r ]] && BUFFER="$c $r" && CURSOR=''${#BUFFER} && zle redisplay && return
      fi
      zle fzf-tab-complete
    }
    zle -N _zf && bindkey '^I' _zf
  '';
in
{
  home.packages = with pkgs; [
    neovim htop ripgrep jq fd yadm bat
    pkgs-unstable.claude-code
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = { navigate = true; line-numbers = true; };
  };

  programs.git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = true;
    };
    settings = {
      user = { name = "Radu T"; email = "radu@rtom.dev"; };
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      gpg.format = "ssh";
      tag.gpgsign = true;
      "url \"ssh://git@gitlab.protontech.ch/\"".insteadOf = "https://gitlab.protontech.ch/";
    };
  };

  programs.lsd = { enable = true; enableZshIntegration = false; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.fzf = { enable = true; enableZshIntegration = true; };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      cd = "z"; ls = "lsd --group-dirs=first"; ll = "lsd -lah --group-dirs=first";
      l = "lsd -A --group-dirs=first"; cat = "bat --style=plain"; vim = "nvim";
      c = "clear"; p = "python"; gg = "lazygit";
      tx = "tmux attach 2>/dev/null || tmux"; np = "ssh naspi"; nas = "ssh nas";
    };
    plugins = [{
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }];
    initContent = ''
      ${prompt}
      ${zoxideFallback}
      chpwd() { lsd -F }
      bindkey '^E' clear-screen
    '';
  };
}

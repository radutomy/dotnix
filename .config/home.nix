{ pkgs, pkgs-unstable, username, ... }:
{
  imports = [ ./modules/neovim.nix ];

  news.display = "silent";
  programs.home-manager.enable = true;

  xdg.configFile."nix/nix.conf".text = "experimental-features = nix-command flakes\n";

  home = {
    inherit username;
    homeDirectory = if username == "root" then "/root" else "/home/${username}";
    stateVersion = "25.11";

    packages = with pkgs; [
	  python3 unzip
      ripgrep jq fd bat nodejs gcc
      htop yadm tmux
      pkgs-unstable.claude-code
      pkgs-unstable.codex
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      extraOptions = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };
    };
  };

}

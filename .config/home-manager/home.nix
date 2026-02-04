{ pkgs, pkgs-unstable, ... }:
{
  news.display = "silent";
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "25.11";

    packages = [
      pkgs.neovim
      pkgs.htop
      pkgs.ripgrep
      pkgs.jq
      pkgs.fd
      pkgs.yadm
      pkgs.bat
      pkgs-unstable.claude-code
    ];
  };
}

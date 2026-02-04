{ pkgs, ... }:
let
  unstable = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/tarball/nixos-unstable") { config.allowUnfree = true; };
in
{
  imports = [
    ../git/config.nix
    ../zsh/config.nix
  ];

  news.display = "silent";
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "25.11";

    packages = with pkgs; [
      neovim htop ripgrep jq fd yadm bat

      # Unstable packages
      unstable.claude-code
    ];
  };
}

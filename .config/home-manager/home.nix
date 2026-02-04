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

  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "25.11";

    packages = with pkgs; [
      neovim htop ripgrep jq fd yadm

      # Unstable packages
      unstable.claude-code
    ];
  };
}

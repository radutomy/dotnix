{ pkgs, unstable, ... }:
{
  imports = [
    ../git/config.nix
    ../helix/config.nix
    ./lang/rust.nix
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

    packages = [
      pkgs.neovim
      pkgs.htop
      pkgs.ripgrep
      pkgs.jq
      pkgs.fd
      pkgs.yadm
      pkgs.bat

      # Unstable packages
      unstable.claude-code
    ];
  };
}

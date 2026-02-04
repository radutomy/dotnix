{ pkgs, pkgs-unstable, ... }:
{
  news.display = "silent";
  programs.home-manager.enable = true;

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
      pkgs-unstable.claude-code
    ];
  };
}

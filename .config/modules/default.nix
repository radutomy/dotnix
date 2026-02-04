{ pkgs, pkgs-unstable, ... }:
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

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
}

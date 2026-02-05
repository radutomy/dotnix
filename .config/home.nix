{ pkgs, pkgs-unstable, username, ... }:
{
  news.display = "silent";
  programs.home-manager.enable = true;

  xdg.configFile."nix/nix.conf".text = "experimental-features = nix-command flakes\n";

  home = {
    inherit username;
    homeDirectory = if username == "root" then "/root" else "/home/${username}";
    stateVersion = "25.11";

    packages = with pkgs; [
      neovim htop ripgrep jq fd yadm bat
      pkgs-unstable.claude-code
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

  programs.tmux.enable = true;
}

# Base home-manager configuration - shared by all hosts
{ username, ... }:
{
  news.display = "silent";
  programs.home-manager.enable = true;

  xdg.configFile."nix/nix.conf".text = "experimental-features = nix-command flakes\n";

  home = {
    inherit username;
    homeDirectory = if username == "root" then "/root" else "/home/${username}";
    stateVersion = "25.11";
  };
}

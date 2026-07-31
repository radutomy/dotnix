# Starts desktop apps and arranges them across COSMIC workspaces.
{ inputs, ... }:
{
  flake.modules.homeManager.coscli =
    { config, pkgs, ... }:
    let
      coscli = inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system};
      desktopEntry = package: name: "${package}/share/applications/${name}.desktop";
      workspaceLayout = pkgs.writeShellApplication {
        name = "cosmic-workspace-layout";
        runtimeInputs = [ coscli ];
        text = ''
          # The only display is group/output 0; workspaces are zero-based.
          cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 30
          cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 30
          sleep 15
          cos-cli move -a spotify -w 1 -g 0 -o 0 --wait 30
          cos-cli move -a discord -w 1 -g 0 -o 0 --wait 30
          cos-cli move -a steam -w 1 -g 0 -o 0 --wait 30
        '';
      };
      workspaceLayoutEntry = pkgs.makeDesktopItem {
        name = "cosmic-workspace-layout";
        desktopName = "COSMIC workspace layout";
        exec = "${workspaceLayout}/bin/cosmic-workspace-layout";
        noDisplay = true;
      };
      bitwardenEntry = pkgs.makeDesktopItem {
        name = "bitwarden";
        desktopName = "Bitwarden";
        exec = "${pkgs.bitwarden-desktop}/bin/bitwarden --autostart";
      };
    in
    {
      home.packages = [ workspaceLayout ];

      xdg.autostart = {
        enable = true;
        entries = [
          (desktopEntry bitwardenEntry "bitwarden")
          (desktopEntry pkgs.spotify "spotify")
          (desktopEntry pkgs.discord "discord")
          (desktopEntry pkgs.steam "steam")
          (desktopEntry config.programs.firefox.package "firefox")
          (desktopEntry pkgs.wezterm "org.wezfurlong.wezterm")
          (desktopEntry workspaceLayoutEntry "cosmic-workspace-layout")
        ];
      };
    };
}

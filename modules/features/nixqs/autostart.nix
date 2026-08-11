{ inputs, ... }:
{
  flake.modules.homeManager.autostart =
    { config, pkgs, ... }:
    let
      coscli = inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system};
      desktopEntry = package: name: "${package}/share/applications/${name}.desktop";
      bitwardenEntry = pkgs.makeDesktopItem {
        name = "bitwarden";
        desktopName = "Bitwarden";
        exec = "${pkgs.bitwarden-desktop}/bin/bitwarden --autostart";
      };
      firefoxEntry = pkgs.makeDesktopItem {
        name = "firefox-autostart";
        desktopName = "Firefox";
        exec = "${config.programs.firefox.finalPackage}/bin/firefox";
      };
      # The only display is group/output 0; workspaces are zero-based, so
      # workspace 0/1 shown as "1"/"2" in the COSMIC workspace switcher.
      workspaceLayout = pkgs.writeShellApplication {
        name = "cosmic-workspace-layout";
        runtimeInputs = [ coscli ];
        text = ''
          cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 30
          cos-cli state -a firefox --maximize
          cos-cli move -a org.wezfurlong.wezterm -w 1 -g 0 -o 0 --wait 30
          cos-cli state -a org.wezfurlong.wezterm --maximize
        '';
      };
      workspaceLayoutEntry = pkgs.makeDesktopItem {
        name = "cosmic-workspace-layout";
        desktopName = "COSMIC workspace layout";
        exec = "${workspaceLayout}/bin/cosmic-workspace-layout";
        noDisplay = true;
      };
    in
    {
      home.packages = [ workspaceLayout ];

      xdg.autostart = {
        enable = true;
        entries = [
          (desktopEntry bitwardenEntry "bitwarden")
          (desktopEntry firefoxEntry "firefox-autostart")
          (desktopEntry pkgs.wezterm "org.wezfurlong.wezterm")
          (desktopEntry workspaceLayoutEntry "cosmic-workspace-layout")
        ];
      };
    };
}

{ inputs, ... }: {
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
      # Autologin starts firefox-autostart before NetworkManager finishes
      # connecting, so eagerly-restored tabs load offline (NS_ERROR_OFFLINE).
      # Block until the network is actually up first.
      firefoxWithNetwork = pkgs.writeShellScript "firefox-with-network" ''
        ${pkgs.networkmanager}/bin/nm-online -q --timeout=10 || true
        exec ${config.programs.firefox.finalPackage}/bin/firefox
      '';
      firefoxEntry = pkgs.makeDesktopItem {
        name = "firefox-autostart";
        desktopName = "Firefox";
        exec = "${firefoxWithNetwork}";
      };
      # The only display is group/output 0; workspaces are zero-based, so
      # workspace 0/1 shown as "1"/"2" in the COSMIC workspace switcher.
      workspaceLayout = pkgs.writeShellApplication {
        name = "cosmic-workspace-layout";
        runtimeInputs = [ coscli ];
        text = ''
          cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
          cos-cli state -a firefox --maximize
          cos-cli move -a org.wezfurlong.wezterm -w 1 -g 0 -o 0 --wait 20
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

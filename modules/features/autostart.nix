{ inputs, ... }: {
  flake.modules.homeManager.autostart =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      coscli = inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system};
      desktopEntry = package: name: "${package}/share/applications/${name}.desktop";
      bitwardenEntry = pkgs.makeDesktopItem {
        name = "bitwarden";
        desktopName = "Bitwarden";
        exec = "${pkgs.bitwarden-desktop}/bin/bitwarden --autostart";
      };
      firefoxWithNetwork = pkgs.writeShellScript "firefox-with-network" ''
        ${pkgs.curl}/bin/curl -fsSo /dev/null -m 5 --retry 100 --retry-all-errors --retry-delay 1 https://detectportal.firefox.com/success.txt
        exec ${config.programs.firefox.finalPackage}/bin/firefox
      '';
      firefoxEntry = pkgs.makeDesktopItem {
        name = "firefox-autostart";
        desktopName = "Firefox";
        exec = "${firefoxWithNetwork}";
      };
      workspaceLayout = pkgs.writeShellApplication {
        name = "cosmic-workspace-layout";
        runtimeInputs = [ coscli ];
        text = config.autostart.workspaceLayout;
      };
      workspaceLayoutEntry = pkgs.makeDesktopItem {
        name = "cosmic-workspace-layout";
        desktopName = "COSMIC workspace layout";
        exec = "${workspaceLayout}/bin/cosmic-workspace-layout";
        noDisplay = true;
      };
    in
    {
      options.autostart.workspaceLayout = lib.mkOption {
        type = lib.types.lines;
        default = ''
          cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
          cos-cli state -a firefox --maximize
          cos-cli move -a org.wezfurlong.wezterm -w 1 -g 0 -o 0 --wait 20
          cos-cli state -a org.wezfurlong.wezterm --maximize
        '';
      };

      config = {
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
    };
}

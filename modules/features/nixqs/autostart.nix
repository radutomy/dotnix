_: {
  flake.modules.homeManager.autostart =
    { config, pkgs, ... }:
    let
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
    in
    {
      xdg.autostart = {
        enable = true;
        entries = [
          (desktopEntry bitwardenEntry "bitwarden")
          (desktopEntry firefoxEntry "firefox-autostart")
        ];
      };
    };
}

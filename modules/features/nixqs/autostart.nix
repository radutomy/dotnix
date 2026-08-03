_: {
  flake.modules.homeManager.autostart =
    { pkgs, ... }:
    let
      desktopEntry = package: name: "${package}/share/applications/${name}.desktop";
      bitwardenEntry = pkgs.makeDesktopItem {
        name = "bitwarden";
        desktopName = "Bitwarden";
        exec = "${pkgs.bitwarden-desktop}/bin/bitwarden --autostart";
      };
    in
    {
      xdg.autostart = {
        enable = true;
        entries = [
          (desktopEntry bitwardenEntry "bitwarden")
        ];
      };
    };
}

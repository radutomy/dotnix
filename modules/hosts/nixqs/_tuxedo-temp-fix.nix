# TODO: (tested broken 2026-10) check if nixpkgs or TUXEDO fixed this upstream; if so, delete this file and its import.
# Test: drop the import and run `nix build .#nixosConfigurations.nixqs.config.boot.kernelPackages.tuxedo-drivers`
# Temporary fixes for tuxedo-drivers:
# - kernel 7.3 needs 4.25+, nixpkgs still has 4.20.1; 4.25 moved its udev rules to files/usr
# - nixpkgs' kmodigest module signing: its Makefile pastes $(MAKEFLAGS) into a shell command, which breaks on the new
#   cmd_sign=...$(space)$@ flag; make passes the flags down through the environment anyway
{
  nixpkgs.overlays = [
    (_: prev: {
      linuxPackages_latest = prev.linuxPackages_latest.extend (
        _: kprev: {
          tuxedo-drivers = kprev.tuxedo-drivers.overrideAttrs (old: {
            version = "4.25.0";
            src = prev.fetchFromGitLab {
              group = "tuxedocomputers";
              owner = "development/packages";
              repo = "tuxedo-drivers";
              rev = "v4.25.0";
              hash = "sha256-AER+JPl3lem1OFV51VdOZAnr3Uy1BFSpEJNrE+shYis=";
            };
            postPatch = (old.postPatch or "") + ''
              substituteInPlace Makefile --replace-fail ' $(MAKEFLAGS)' ""
              mv files/usr usr
            '';
          });
        }
      );
    })
  ];
}

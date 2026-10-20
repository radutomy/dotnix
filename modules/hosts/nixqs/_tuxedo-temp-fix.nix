# TODO: (tested broken 2026-10) check if nixpkgs or TUXEDO fixed this upstream; if so, delete this file and its import.
# Test: drop the import and run `nix build .#nixosConfigurations.nixqs.config.boot.kernelPackages.tuxedo-drivers`
# Temporary: fix tuxedo-drivers for nixpkgs' kmodigest module signing.
# - its Makefile pastes $(MAKEFLAGS) into a shell command, which breaks on the new
#   cmd_sign=...$(space)$@ flag; make passes the flags down through the environment anyway
# - the install now also runs depmod, whose index files collide with the kernel's;
#   NixOS regenerates them for the merged module tree
{
  nixpkgs.overlays = [
    (_: prev: {
      linuxPackages_latest = prev.linuxPackages_latest.extend (
        _: kprev: {
          tuxedo-drivers = kprev.tuxedo-drivers.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace Makefile --replace-fail ' $(MAKEFLAGS)' ""
            '';
            postInstall = old.postInstall + ''
              rm $out/lib/modules/*/modules.*
            '';
          });
        }
      );
    })
  ];
}

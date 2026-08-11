# Pins mesa to 26.1.6: 26.2.0 deterministically hangs the i915 driver on the
# nixqs Arrow Lake iGPU (GPU HANG + context reset on essentially every
# GPU-accelerated app launch, e.g. wezterm). Bisected across 5 system
# generations, isolating kernel version, mesa version, and wezterm version
# independently - only the mesa bump reproduces it.
#
# To update mesa once upstream fixes the regression: delete this file, and
# remove its `imports` line from hardware-configuration.nix.
_: {
  flake.modules.nixos.nixqsMesaPin =
    { pkgs, ... }:
    let
      mesaPinPkgs = import
        (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/b7c2ada94fe99c15b0dbcf4d11fd7850b957a436.tar.gz";
          sha256 = "1hw875y585lkhygn09kcbmdgm58b0nb5k0d38qwlvfngprsnp2r0";
        })
        {
          system = pkgs.system;
          config.allowUnfree = true;
        };
    in
    {
      hardware.graphics.package = mesaPinPkgs.mesa;
      hardware.graphics.package32 = mesaPinPkgs.pkgsi686Linux.mesa;
    };
}

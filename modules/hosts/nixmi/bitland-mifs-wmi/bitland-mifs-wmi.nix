# Xiaomi platform driver with the Book Pro 14 power-mode fixes, until they land upstream.
# To drop it: remove this folder and its line in ../main.nix.
_: {
  flake.modules.nixos.nixmi-bitland-mifs-wmi =
    { config, pkgs, ... }:
    let
      kernel = config.boot.kernelPackages.kernel;
    in
    {
      boot.extraModulePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "bitland-mifs-wmi-xiaomi";
          inherit (kernel) src version;
          patches = [
            ./1-detect-failed-calls.patch
            ./2-ac-type-optional.patch
            ./3-set-response-function-id.patch
            ./4-xiaomi-book-pro-14-profiles.patch
            ./5-xiaomi-profile-mapping.patch
            ./6-xiaomi-fan-speeds.patch
          ];
          nativeBuildInputs = kernel.moduleBuildDependencies;
          buildPhase = ''
            mkdir module
            cp drivers/platform/x86/bitland-mifs-wmi.c module/
            echo "obj-m := bitland-mifs-wmi.o" > module/Makefile
            make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD/module modules
          '';
          installPhase = ''
            install -Dm644 module/bitland-mifs-wmi.ko $out/lib/modules/${kernel.modDirVersion}/updates/bitland-mifs-wmi.ko
          '';
        })
      ];
    };
}

{ inputs, ... }: {
  flake.modules.nixos.nixpiHardware = { pkgs, ... }: {
    imports = [ inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base ];
    boot = {
      kernelPackages = pkgs.linuxPackages;
      loader.raspberry-pi.useGenerationDeviceTree = true;
    };
    zramSwap.enable = true;
  };
}

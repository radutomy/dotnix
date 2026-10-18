# Book Pro 14 (2026), Intel 358H, 32 GiB RAM
_: {
  flake.modules.nixos.nixmi-hardware = { pkgs, ... }: {
    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "kvm-intel" ];
      # The upstream PSR2 quirk matches b081, not the 358H's B390 (b080).
      # Keep this display workaround until verified on the actual panel.
      kernelParams = [ "xe.enable_psr=0" ];
    };

    hardware = {
      cpu.intel.updateMicrocode = true;
      bluetooth.enable = true;
      firmware = [ pkgs.sof-firmware ];
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
      };
    };

    services = {
      thermald = {
        enable = true;
        ignoreCpuidCheck = true;
      };
      hardware.bolt.enable = true;
    };
  };
}

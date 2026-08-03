# TUXEDO Stellaris 16 - Gen 7 Intel (board X6AR5xxY).
# Core Ultra 9 275HX, Intel Arrow Lake iGPU + NVIDIA Blackwell dGPU.
_: {
  flake.modules.nixos.nixqsHardware =
    {
      config,
      pkgs,
      ...
    }:
    {
      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      nixpkgs.hostPlatform = "x86_64-linux";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;

        tuxedo-drivers.enable = true;

        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            vpl-gpu-rt
          ];
        };

        nvidia = {
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.production;

          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = true;

          nvidiaSettings = false;
          videoAcceleration = false;

          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:2:0:0";
          };
        };
      };

      services = {
        # Loads the nvidia kernel module and blacklists nouveau. Still the
        # correct switch under Wayland-only COSMIC.
        xserver.videoDrivers = [ "nvidia" ];

        thermald.enable = true;

        # The Thunderbolt domain comes up at security level "user", so attached
        # devices stay unauthorised until boltd approves them.
        hardware.bolt.enable = true;

        # BIOS and EC updates, for the vendor firmware published on LVFS.
        fwupd.enable = true;

        # The under-chassis lightbar powers on at full brightness and has no
        # hotkey of its own. systemd saves and restores the keyboard backlight
        # but not this, so without a rule it returns on every boot.
        udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="leds", KERNEL=="rgb:lightbar", ATTR{brightness}="0"
        '';
      };
    };
}

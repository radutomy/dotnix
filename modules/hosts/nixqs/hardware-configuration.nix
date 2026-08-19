# TUXEDO Stellaris 16 - Gen 7 Intel (board X6AR5xxY).
# Core Ultra 9 275HX, Intel Arrow Lake iGPU + NVIDIA Blackwell dGPU.
{ self, ... }:
{
  flake.modules.nixos.nixqsHardware =
    {
      config,
      pkgs,
      ...
    }:
    {
      # Pins mesa to 26.1.6 (see mesa-pin.nix) because 26.2.0 deterministically
      # hangs the i915 driver on this Arrow Lake iGPU.
      # To test whether a newer mesa fixes it: comment out this line, `git add -A`,
      # re-eval/switch, and check `nix eval .#nixosConfigurations.nixqs.config.hardware.graphics.package.version`
      # plus a real GPU workload (e.g. launch wezterm a few times) for GPU HANG
      # entries in `journalctl -k -b`. If it's clean, delete this line and
      # mesa-pin.nix for good; otherwise put the line back.
      imports = [ self.modules.nixos.nixqsMesaPin ];

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

        thermald = {
          enable = true;
          ignoreCpuidCheck = true;
        };

        # The Thunderbolt domain comes up at security level "user", so attached
        # devices stay unauthorised until boltd approves them.
        hardware.bolt.enable = true;

        udev.extraRules = ''
          # The under-chassis lightbar powers on at full brightness and has no
          # hotkey of its own. systemd saves and restores the keyboard backlight
          # but not this, so without a rule it returns on every boot.
          ACTION=="add", SUBSYSTEM=="leds", KERNEL=="rgb:lightbar", ATTR{brightness}="0"

          # The webcam's IR sensor (for Windows Hello) is indistinguishable from
          # the real camera to apps, so they sometimes pick it and show black.
          # Unbind its driver so its /dev/video* nodes never exist.
          ACTION=="bind", SUBSYSTEM=="usb", DRIVER=="uvcvideo", ATTRS{interface}=="IR Camera", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/uvcvideo/unbind'"
        '';
      };
    };
}

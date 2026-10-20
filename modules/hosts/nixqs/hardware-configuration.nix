# TUXEDO Stellaris 16 - Gen 7 Intel (board X6AR5xxY).
# Core Ultra 9 275HX, Intel Arrow Lake iGPU + NVIDIA Blackwell dGPU.
_: {
  flake.modules.nixos.nixqs-hardware =
    { pkgs, ... }:
    {
      imports = [ ./_tuxedo-temp-fix.nix ];

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
        # Intel only (see the NVIDIA udev rules below)
        blacklistedKernelModules = [ "nouveau" ];
      };

      hardware = {
        cpu.intel.updateMicrocode = true;

        tuxedo-drivers = {
          enable = true;
          # Mostly plugged in: cap charging at 80% to slow battery wear
          settings.charging-profile = "stationary";
        };

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

          # Intel only: hybrid graphics put COSMIC and apps on different GPUs, which froze Firefox
          # and glitched the display. Remove the NVIDIA GPU and its HDMI audio so nothing uses
          # them and they power down; every display output in use is wired to Intel anyway.
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        '';
      };
    };
}

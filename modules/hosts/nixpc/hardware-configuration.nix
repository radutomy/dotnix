_: {
  flake.modules.nixos.nixpcHardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [
          "kvm-amd"
          "nct6687"
        ];
        extraModulePackages = [ config.boot.kernelPackages.nct6687d ];
        blacklistedKernelModules = [ "nct6683" ];
        extraModprobeConfig = "options nct6687 force=1";
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.amdgpu.overdrive.enable = true;
      services = {

        lact = {
          enable = true;
          settings = {
            version = 6;
            daemon.log_level = "info";
            gpus."1002:744C-1DA2:471E-0000:03:00.0" = {
              performance_level = "manual";
              voltage_offset = -65;
              fan_control_enabled = false;
              pmfw_options.acoustic_limit = 1980;
            };
          };
        };

        udev.extraRules = ''
          # Power off the unused Windows drive (WD_BLACK SN770) to keep it cool
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", \
            ATTR{device}=="0x5017", ATTR{remove}="1"

          # Fix the pump at 45% and the front SSD fan at 10% (PWM range: 0–255)
          ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="nct6687", \
            ATTR{pwm2_enable}="1", ATTR{pwm2}="115", \
            ATTR{pwm4_enable}="1", ATTR{pwm4}="26"
        '';

        # The MAD receiver does not advertise its active sensor resolution, so
        # libinput otherwise falls back to 1000 DPI and misclassifies motion speed.
        udev.extraHwdb = ''
          mouse:usb:v373bp1040:name:Compx MAD 8K DONGLE*:*
           MOUSE_DPI=1600@1000
        '';

        # Hide unused audio devices (GPU HDMI outputs, webcam mic, and the
        # onboard/FiiO inputs and outputs we never use).
        pipewire.wireplumber.extraConfig."51-audio-devices" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "device.name" = "alsa_card.pci-0000_03_00.1"; }
                { "device.name" = "alsa_card.pci-0000_12_00.1"; }
                { "device.name" = "alsa_card.usb-SJ-180517-N_1080P_Webcam-02"; }
              ];
              actions.update-props."device.disabled" = true;
            }
            {
              matches = [
                { "node.name" = "alsa_output.usb-Generic_USB_Audio-00.HiFi__Headphones__sink"; }
                { "node.name" = "alsa_input.usb-Generic_USB_Audio-00.HiFi__Line__source"; }
                { "node.name" = "alsa_input.usb-FiiO_DigiHug_USB_Audio-01.analog-stereo"; }
              ];
              actions.update-props."node.disabled" = true;
            }
          ];
        };
      };
    };
}

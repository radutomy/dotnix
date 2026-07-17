_: {
  flake.modules.nixos.nixpcHardware =
    { config, ... }:
    {
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

      nixpkgs.hostPlatform = "x86_64-linux";
      hardware = {
        enableRedistributableFirmware = true;
        cpu.amd.updateMicrocode = true;
        amdgpu.overdrive.enable = true;
      };

      # Control the CPU, pump, and front SSD fans
      systemd.services.fan-control = {
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        script = ''
          temp=(/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input)
          fan=(/sys/devices/platform/nct6687.*/hwmon/hwmon*)
          while sleep 2; do
            c=$(( $(<"$temp") / 1000 ))

            if ((c <= 60)); then
              value=107 # ≤60°C: 42%
            elif ((c <= 70)); then
              value=$((107 + (c - 60) * 15 / 10)) # 60–70°C: 42–48%
            elif ((c <= 80)); then
              value=$((122 + (c - 70) * 31 / 10)) # 70–80°C: 48–60%
            elif ((c <= 85)); then
              value=$((153 + (c - 80) * 26 / 5)) # 80–85°C: 60–70%
            else
              value=179 # >85°C: 70%
            fi

            echo 1 > "$fan/pwm1_enable"
            echo "$value" > "$fan/pwm1"

            # Pump: 47%
            echo 1 > "$fan/pwm2_enable"
            echo 120 > "$fan/pwm2"

            # Front SSD fan: 10%
            echo 1 > "$fan/pwm4_enable"
            echo 26 > "$fan/pwm4"
          done
        '';
        serviceConfig = {
          Restart = "always";
          RestartSec = "2s";
        };
      };

      services = {
        # Undervolt the GPU and keep the fan capped at 2000 RPM
        lact = {
          enable = true;
          settings = {
            version = 6;
            daemon.log_level = "info";
            gpus."1002:744C-1DA2:471E-0000:03:00.0" = {
              performance_level = "manual";
              voltage_offset = -65;
              fan_control_enabled = false;
              pmfw_options.acoustic_limit = 2000;
            };
          };
        };

        # Power off the unused Windows drive (WD_BLACK SN770) to keep it cool
        udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", \
            ATTR{device}=="0x5017", ATTR{remove}="1"
        '';

        # The MAD mouse receiver does not advertise its active sensor resolution, so
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

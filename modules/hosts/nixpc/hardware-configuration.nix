_: {
  flake.modules.nixos.nixpcHardware = { config, pkgs, ... }: {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "uas"
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
      wooting.enable = true;
    };

    # Control the CPU, pump, and front SSD fans
    systemd.services.fan-control = {
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      script = ''
        temp=(/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input)
        fan=(/sys/devices/platform/nct6687.*/hwmon/hwmon*)
        t=$(( $(<"$temp") / 100 )) # tenths of °C
        while sleep 2; do
          # Follow a slow average (~15 s) so short Tctl bursts don't spike the fan
          t=$(( t + ($(<"$temp") / 100 - t) / 8 ))

          if ((t <= 600)); then
            value=107 # ≤60°C: 42%
          elif ((t < 850)); then
            value=$((107 + (t - 600) * 29 / 250)) # 60–85°C: 42–53%
          elif ((t < 950)); then
            value=$((136 + (t - 850) * 17 / 100)) # 85–95°C: 53–60%
          else
            value=166 # ≥95°C (TjMax): 65%
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
          version = 7;
          daemon = {
            log_level = "info";
            admin_group = "wheel";
          };
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

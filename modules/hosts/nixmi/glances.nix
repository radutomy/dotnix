_: {
  flake.modules.nixos.nixmi-glances =
    { pkgs, ... }:
    let
      # Whole-laptop draw, power mode and the CPU power caps the firmware set for it
      power-panel = pkgs.writeShellApplication {
        name = "power-panel";
        runtimeInputs = with pkgs; [
          coreutils
          gawk
          gnugrep
        ];
        text = ''
          battery=/sys/class/power_supply/BAT0
          caps=/sys/class/powercap/intel-rapl-mmio:0
          profile=$(dirname "$(grep -lx bitland-mifs-wmi /sys/class/platform-profile/*/name)")/profile

          # The battery meters the whole laptop, but only while it is the power source
          if [ "$(<$battery/status)" = Discharging ]; then
            awk '{ printf "System  %.1f W\n", $1 / 1e6 }' $battery/power_now
          else
            echo "System  on charger, not metered"
          fi

          case $(<"$profile") in
            low-power) echo "Mode    Quiet" ;;
            balanced) echo "Mode    Smart" ;;
            balanced-performance) echo "Mode    Balanced" ;;
            performance) echo "Mode    Performance" ;;
          esac

          # The firmware sets each mode's CPU power caps through the MMIO RAPL interface
          echo "Limit   $(($(<$caps/constraint_0_power_limit_uw) / 1000000)) W (burst $(($(<$caps/constraint_1_power_limit_uw) / 1000000)) W)"
        '';
      };
    in
    {
      environment.systemPackages = [ pkgs.glances ];

      home-manager.users.radu.xdg.configFile."glances/glances.conf".text = ''
        [global]
        refresh=2

        [load]
        disable=True

        [mem]
        disable=True

        [memswap]
        disable=True

        [network]
        disable=True

        [connections]
        disable=True

        [diskio]
        disable=True

        [fs]
        disable=True

        [irq]
        disable=True

        [processlist]
        disable=True

        [wifi]
        disable=True

        [npu]
        disable=True

        [sensors]
        show=Package id 0,Composite,iwlwifi_1 0,Left Fan,Right Fan,Battery
        alias=Package id 0:CPU,Composite:NVMe,iwlwifi_1 0:WiFi

        [amp_power]
        enable=true
        refresh=2
        command=${power-panel}/bin/power-panel
      '';
    };
}

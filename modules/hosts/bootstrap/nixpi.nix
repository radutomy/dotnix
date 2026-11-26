# nix run .#nixpi-image -- <hostname> <wifi-ssid> <wifi-password> <device>
{ self, ... }: {
  perSystem = { lib, pkgs, ... }: {
    apps.nixpi-image.program = pkgs.writeShellApplication {
      name = "nixpi-image";
      runtimeInputs = [ pkgs.networkmanager ];
      text = ''
        device="''${4:?Usage: nixpi-image <hostname> <wifi-ssid> <wifi-password> <device>}"
        if [ "$(lsblk -dnro TYPE,RM "$device")" != "disk 1" ]; then
          echo "$device is not a removable disk" >&2
          exit 1
        fi
        wifi=$(nmcli --offline connection add type wifi con-name wifi ssid "$2" \
          wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$3")
        image=$(nix build -L --no-link --print-out-paths "${self}#nixosConfigurations.$1.config.system.build.sdImage")
        ${lib.getExe' pkgs.util-linux "lsblk"} -nrpo NAME --filter 'TYPE == "part" && MOUNTPOINT =~ "."' "$device" |
          xargs -r -n1 sudo umount --all-targets

        images=("$image"/sd-image/*.img)
        sudo dd if="''${images[0]}" of="$device" bs=4M oflag=direct conv=fsync status=progress
        sudo blockdev --rereadpt "$device"
        udevadm settle
        printf '%s\n' "$wifi" | sudo ${lib.getExe' pkgs.systemd "systemd-dissect"} --fsck=no --with "$device" \
          install -D -m 600 /dev/stdin etc/NetworkManager/system-connections/wifi.nmconnection
      '';
    };
  };
}

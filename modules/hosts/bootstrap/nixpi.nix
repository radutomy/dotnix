# nix run .#nixpi-image -- <hostname> <wifi-ssid> <wifi-password> <device>
# nix run .#nixpi-image -- nixpi IoT 'ihavenoidea' /dev/sda
{ self, ... }: {
  perSystem = { pkgs, ... }: {
    apps.nixpi-image.program = pkgs.writeShellApplication {
      name = "nixpi-image";
      text = ''
        if [ "$(lsblk -dno RM "$4")" != 1 ]; then
          echo "$4 is not a removable disk" >&2
          exit 1
        fi
        image=$(PI_HOSTNAME=$1 WIFI_SSID=$2 WIFI_PSK=$3 nix build --impure --no-link --print-out-paths ${self}#nixosConfigurations.nixpi.config.system.build.sdImage)
        sudo umount "$4"?* 2>/dev/null || true
        sudo dd if="$image/sd-image/${self.nixosConfigurations.nixpi.config.image.fileName}" of="$4" bs=4M oflag=direct conv=fsync status=progress
      '';
    };
  };
}

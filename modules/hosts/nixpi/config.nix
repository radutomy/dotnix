{ inputs, ... }: {
  flake.modules.nixos.nixpi-config = { lib, pkgs, ... }: {
    imports = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
    nixpkgs.hostPlatform = "aarch64-linux";
    boot.supportedFilesystems.zfs = lib.mkForce false;
    sdImage.compressImage = false;
    sdImage.populateRootCommands = ''
      install -D -m 600 ${pkgs.writeText "wifi" ''
        [wifi]
        ssid=${builtins.getEnv "WIFI_SSID"}
        [wifi-security]
        key-mgmt=wpa-psk
        psk=${builtins.getEnv "WIFI_PSK"}
      ''} files/etc/NetworkManager/system-connections/wifi.nmconnection
    '';
    networking.networkmanager.enable = true;

    systemd.services.dotnix-clone = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      script = "[ -d /root/dotnix ] || ${lib.getExe pkgs.git} clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix /root/dotnix";
    };
  };
}

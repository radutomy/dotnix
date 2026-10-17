{ self, inputs, ... }:
let
  hostnames = [
    "nixpi"
    "nixpi-1"
    "nixpi-2"
    "nixpi-qs"
  ];
in
{
  flake.modules.nixos.nixpi = { lib, pkgs, ... }: {
    imports = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
    nixpkgs.hostPlatform = "aarch64-linux";
    boot.supportedFilesystems.zfs = lib.mkForce false;
    system.stateVersion = "26.05";
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
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
    ];

    systemd.services.dotnix-clone = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      script = "[ -d /root/dotnix ] || ${lib.getExe pkgs.git} clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix /root/dotnix";
    };

    home-manager.users.root.imports = with self.modules.homeManager; [
      base
      ai
      fish
      git
      tmux
      nvim
    ];
  };

  flake.nixosConfigurations = inputs.nixpkgs.lib.genAttrs hostnames (
    name:
    inputs.nixpkgs.lib.nixosSystem {
      modules = with self.modules.nixos; [
        base
        nixpi
        { networking.hostName = name; }
      ];
    }
  );
}

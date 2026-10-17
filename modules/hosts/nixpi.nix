{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      (
        {
          lib,
          pkgs,
          modulesPath,
          ...
        }:
        {
          imports = [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
          nixpkgs.hostPlatform = "aarch64-linux";
          boot.supportedFilesystems.zfs = lib.mkForce false;
          system.stateVersion = "26.05";

          # Only baked into the image, so rebuilds on the Pi leave them alone
          sdImage.compressImage = false;
          sdImage.populateRootCommands = ''
            install -D ${pkgs.writeText "hostname" (builtins.getEnv "PI_HOSTNAME")} files/etc/hostname
            install -D -m 600 ${pkgs.writeText "wifi" ''
              [wifi]
              ssid=${builtins.getEnv "WIFI_SSID"}
              [wifi-security]
              key-mgmt=wpa-psk
              psk=${builtins.getEnv "WIFI_PSK"}
            ''} files/etc/NetworkManager/system-connections/wifi.nmconnection
          '';

          networking.hostName = "";
          networking.networkmanager.enable = true;
          networking.networkmanager.settings.main.hostname-mode = "none";
          services.openssh.enable = true;
          systemd.services.dotnix-clone = {
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            unitConfig.ConditionPathExists = "!/root/dotnix";
            serviceConfig.Type = "oneshot";
            path = [ pkgs.git ];
            script = "git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix /root/dotnix";
          };
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3TKS95kYiNDSmdFXcK2NjVCkUVwtgf7YdCaC3eZ3JG rtomuleasa@quantum-systems.com"
          ];

          home-manager.users.root.imports = with self.modules.homeManager; [
            base
            ai
            fish
            git
            tmux
            nvim
          ];
        }
      )
    ];
  };
}

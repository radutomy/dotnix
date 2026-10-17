{ self, inputs, ... }:
let
  hostModule = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.sshd
      self.modules.nixos.nas-config
      self.modules.nixos.nasOSDisko
      self.modules.nixos.nasHardware
    ];

    home-manager.users.root.imports = [ self.modules.homeManager.base ];
  };
in
{
  flake.nixosConfigurations = {
    nas = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        hostModule
        self.modules.nixos.adguard
        self.modules.nixos.alerts
        self.modules.nixos.filebrowser
        self.modules.nixos.glances
        self.modules.nixos.home-assistant
        self.modules.nixos.immich
        self.modules.nixos.rclone
        self.modules.nixos.tailscale
        self.modules.nixos.nixflix
      ];
    };

    # alternate boot configs for the same machine
    nasFullReinstall = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        hostModule
        self.modules.nixos.nasDataDisko
      ];
    };

    nasOSRecovery = inputs.nixpkgs.lib.nixosSystem {
      modules = [ hostModule ];
    };
  };
}

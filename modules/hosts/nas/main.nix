{ self, inputs, ... }:
let
  homeModule = {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.ai
      self.modules.homeManager.fish
      self.modules.homeManager.git
      self.modules.homeManager.tmux
      self.modules.homeManager.nvim
    ];
  };

  hostModule = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.nas-config
      self.modules.nixos.nasOSDisko
      self.modules.nixos.nasHardware
    ];

    home-manager.users.root = homeModule;
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
        self.modules.nixos.nfs
        self.modules.nixos.rclone
        self.modules.nixos.tailscale
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

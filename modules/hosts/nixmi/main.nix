{ self, inputs, ... }: {
  flake.nixosConfigurations.nixmi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.desktop
      self.modules.nixos.nixmi-config
      self.modules.nixos.nixmi-glances
      self.modules.nixos.nixmiDisko
      self.modules.nixos.preservation
      self.modules.nixos.nixmiHardware
      self.modules.nixos.nixmi-bitland-mifs-wmi
      self.modules.nixos.work
      {
        home-manager.users.radu = {
          imports = [
            self.modules.homeManager.desktop
            self.modules.homeManager.autostart
            self.modules.homeManager.nixmi-autostart
          ];
        };
      }
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosConfigurations.nixqs = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.desktop
      self.modules.nixos.nixqs-config
      self.modules.nixos.nixqsDisko
      self.modules.nixos.preservation
      self.modules.nixos.nixqsHardware
      self.modules.nixos.work
      {
        home-manager.users.radu = {
          imports = [
            self.modules.homeManager.desktop
            self.modules.homeManager.autostart
          ];
        };
      }
    ];
  };
}

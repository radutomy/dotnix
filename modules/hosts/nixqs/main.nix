{ self, inputs, ... }: {
  flake.nixosConfigurations.nixqs = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.desktop
      self.modules.nixos.nixqs-config
      self.modules.nixos.nixqsDisko
      self.modules.nixos.nixqsPreservation
      self.modules.nixos.nixqsHardware
      self.modules.nixos.work
      {
        home-manager.users.radu = { pkgs, ... }: {
          imports = [
            self.modules.homeManager.desktop
            self.modules.homeManager.autostart
          ];
          home.packages = [ pkgs.teams-for-linux ];
        };
      }
    ];
  };
}

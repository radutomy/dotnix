{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.desktop
      self.modules.nixos.nixpc-config
      self.modules.nixos.nixpcDisko
      self.modules.nixos.nixpcPreservation
      self.modules.nixos.nixpcHardware
      {
        home-manager.users.radu = { pkgs, ... }: {
          imports = [
            self.modules.homeManager.desktop
            self.modules.homeManager.glances
          ];
          home.packages = [ pkgs.discord ];
        };
      }
    ];
  };
}

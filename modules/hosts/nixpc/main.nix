{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.desktop
      self.modules.nixos.nixpc-config
      self.modules.nixos.nixpcDisko
      self.modules.nixos.preservation
      self.modules.nixos.nixpcHardware
      self.modules.nixos.work
      {
        home-manager.users.radu = { pkgs, ... }: {
          imports = [
            self.modules.homeManager.desktop
            self.modules.homeManager.glances
            self.modules.homeManager.autostart
          ];
          home.packages = [ pkgs.discord ];
        };
      }
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpi = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixpi-config
      self.modules.nixos.nixpiHardware
      self.modules.nixos.nixpiDisko
      {
        home-manager.users.root.imports = [
          self.modules.homeManager.base
          self.modules.homeManager.ai
          self.modules.homeManager.fish
          self.modules.homeManager.git
          self.modules.homeManager.tmux
          self.modules.homeManager.nvim
        ];
      }
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosConfigurations.nixmi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.nixmi-glances
      self.modules.nixos.nixmi-disko
      self.modules.nixos.nixmi-hardware
      self.modules.nixos.nixmi-bitland-mifs-wmi
      self.modules.nixos.moonlight
      self.modules.nixos.radio-tailscale-pc
      self.modules.nixos.nixmi-config
    ];
  };
}

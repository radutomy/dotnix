{ self, inputs, ... }: {
  flake.nixosConfigurations.nixqs = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.sshd
      self.modules.nixos.nixqs-disko
      self.modules.nixos.nixqs-hardware
      self.modules.nixos.sunshine
      self.modules.nixos.radio-cable
      self.modules.nixos.radio-tailscale-pc
      self.modules.nixos.nixqs-config
    ];
  };
}

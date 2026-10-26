{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.sshd
      self.modules.nixos.nixpc-glances
      self.modules.nixos.nixpc-disko
      self.modules.nixos.nixpc-hardware
      self.modules.nixos.moonlight
      self.modules.nixos.radio-tailscale-pc
      self.modules.nixos.nixpc-config
    ];
  };
}

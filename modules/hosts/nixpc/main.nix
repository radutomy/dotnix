{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_xwayland-diagnostics.nix
      self.modules.nixos.desktop
      self.modules.nixos.nixpc-glances
      self.modules.nixos.nixpc-disko
      self.modules.nixos.nixpc-hardware
      self.modules.nixos.moonlight
      self.modules.nixos.radiotunnel-pc
      self.modules.nixos.nixpc-config
    ];
  };
}

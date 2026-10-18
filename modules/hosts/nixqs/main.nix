{ self, inputs, ... }: {
  flake.nixosConfigurations.nixqs = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.nixqsDisko
      self.modules.nixos.nixqsHardware
      self.modules.nixos.sunshine
      self.modules.nixos.radiocable
      {
        networking.hostName = "nixqs";
        home-manager.users.radu.tmux.layout = "laptop";
        services.tailscale.extraSetFlags = [ "--accept-routes" ];
      }
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosConfigurations.nixmi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.nixmi-glances
      self.modules.nixos.nixmi-disko
      self.modules.nixos.nixmi-hardware
      self.modules.nixos.nixmi-bitland-mifs-wmi
      self.modules.nixos.moonlight
      {
        networking.hostName = "nixmi";
        home-manager.users.radu.tmux.layout = "laptop";
        services.tailscale.extraSetFlags = [ "--accept-routes" ];
        services.fprintd.enable = true;
        preservation.preserveAt."/persistent".directories = [ "/var/lib/fprint" ];
      }
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosConfigurations.nixmi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.desktop
      self.modules.nixos.nixmi-glances
      self.modules.nixos.nixmiDisko
      self.modules.nixos.nixmiHardware
      self.modules.nixos.nixmi-bitland-mifs-wmi
      self.modules.nixos.moonlight
      {
        networking.hostName = "nixmi";
        services.tailscale.extraSetFlags = [ "--accept-routes" ];
        services.fprintd.enable = true;
        preservation.preserveAt."/persistent".directories = [ "/var/lib/fprint" ];
      }
    ];
  };
}

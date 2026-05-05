{ self, inputs, ... }:
{
  perSystem =
    { mkBootstrapApp, ... }:
    {
      apps.nas.program = mkBootstrapApp "nas";
    };

  flake.nixosConfigurations.nas = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      self.nixosModules.base
      self.nixosModules.fish
      self.nixosModules.git
      self.nixosModules.nvim
      self.nixosModules.tailscale
      self.nixosModules.tmux
      self.nixosModules.nas
      self.nixosModules.nasBootDisko
      self.nixosModules.nasDataDisko
      self.nixosModules.nasHardware
    ];
  };
}

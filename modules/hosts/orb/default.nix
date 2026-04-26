{ self, inputs, ... }:
{
  perSystem =
    { mkBootstrapApp, ... }:
    {
      apps.orb.program = mkBootstrapApp "orb";
    };

  flake.nixosConfigurations.orb = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      self.nixosModules.base
      self.nixosModules.fish
      self.nixosModules.git
      self.nixosModules.nvim
      self.nixosModules.orb
      self.nixosModules.rust
      self.nixosModules.csharp
      self.nixosModules.tmux
      self.nixosModules.work
    ];
  };
}

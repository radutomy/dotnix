{ self, inputs, ... }:
{
  perSystem =
    { mkBootstrapApp, ... }:
    {
      apps.wsl.program = mkBootstrapApp "wsl";
    };

  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.base
      self.nixosModules.fish
      self.nixosModules.git
      self.nixosModules.nvim
      self.nixosModules.rust
      self.nixosModules.csharp
      self.nixosModules.tmux
      self.nixosModules.work
      self.nixosModules.wsl
    ];
  };
}

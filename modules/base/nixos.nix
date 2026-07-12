# Shared NixOS configuration.
{ inputs, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      nixpkgs.config.allowUnfree = true;
      programs.fish.enable = true;
      users.users.root.shell = pkgs.fish;
    };
}

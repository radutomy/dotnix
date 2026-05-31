# what every NixOS host gets: root's home is managed by home-manager, fish
# is the login shell, and ns rebuilds the whole system, home included
{ inputs, ... }:
let
  dotnix = "$HOME/dotnix";
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      programs.fish.enable = true;
      users.users.root.shell = pkgs.fish;
      # overrides the home-manager defaults in home.nix
      home-manager.users.root.home.shellAliases = {
        ns = "nh os switch ${dotnix} --bypass-root-check";
        nu = "nh os switch ${dotnix} --bypass-root-check --update && git -C ${dotnix} commit -m 'flake.lock' -- flake.lock && git -C ${dotnix} push";
      };
    };
}

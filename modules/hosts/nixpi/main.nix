{ self, inputs, ... }:
let
  hostnames = [
    "nixpi"
    "nixpi-1"
    "nixpi-2"
    "nixpi-qs"
  ];
in
{
  flake.nixosConfigurations = inputs.nixpkgs.lib.genAttrs hostnames (
    name:
    inputs.nixpkgs.lib.nixosSystem {
      modules =
        with self.modules.nixos;
        [
          base
          sshd
          nixpi
          {
            networking.hostName = name;
            home-manager.users.root.imports = [ self.modules.homeManager.base ];
          }
        ]
        ++ inputs.nixpkgs.lib.optional (name == "nixpi-qs") radiotunnel-pi;
    }
  );
}

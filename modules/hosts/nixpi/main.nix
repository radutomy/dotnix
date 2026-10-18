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
      modules = [
        self.modules.nixos.base
        self.modules.nixos.sshd
        self.modules.nixos.nixpi-config
        {
          networking.hostName = name;
          home-manager.users.root.imports = [ self.modules.homeManager.base ];
        }
      ]
      ++ inputs.nixpkgs.lib.optional (name == "nixpi-qs") self.modules.nixos.radiotunnel-pi;
    }
  );
}

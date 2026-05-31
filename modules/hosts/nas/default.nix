{ self, inputs, ... }:
let
  commonModules = [
    self.nixosModules.base
    self.nixosModules.ai
    self.nixosModules.fish
    self.nixosModules.git
    self.nixosModules.nas
    self.nixosModules.nasOSDisko
    self.nixosModules.nasHardware
  ];
in
{
  perSystem =
    { mkBootstrapApp, ... }:
    {
      apps.nas.program = mkBootstrapApp "nas";
    };

  flake.nixosConfigurations = {

    # this gets used when executing `ns` command
    nas = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        self.nixosModules.glances
        self.nixosModules.samba
        self.nixosModules.tmux
        self.nixosModules.tailscale
        self.nixosModules.nvim
      ]
      ++ commonModules;
    };

    nasFullReinstall = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        self.nixosModules.nasDataDisko
      ]
      ++ commonModules;
    };

    nasOSRecovery = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
      ]
      ++ commonModules;
    };

    # wipes and reconfigures the zpool
    nasDataWiper = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        self.nixosModules.nasDataDisko
      ];
    };
  };
}

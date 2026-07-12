{ self, inputs, ... }:
let
  mkNasHost =
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = common ++ modules;
    };

  common = with self.modules.nixos; [
    base
    nas-config
    nasOSDisko
    nasHardware
    {
      home-manager.users.root.imports = with self.modules.homeManager; [
        base
        ai
        fish
        git
        tmux
        nvim
      ];
    }
  ];
in
{
  flake.nixosConfigurations = {
    nas = mkNasHost (
      with self.modules.nixos;
      [
        adguard
        caddy
        glances
        home-assistant
        immich
        invidious
        owncloud
        rclone
        samba
        tailscale
      ]
    );

    # alternate boot configs for the same machine
    nasFullReinstall = mkNasHost [ self.modules.nixos.nasDataDisko ];
    nasOSRecovery = mkNasHost [ ];

    # wipes and reconfigures the zpool; only its diskoScript is ever used
    nasDataWiper = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ self.modules.nixos.nasDataDisko ];
    };
  };
}

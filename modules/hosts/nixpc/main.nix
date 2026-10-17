{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_xwayland-diagnostics.nix
      self.modules.nixos.desktop
      self.modules.nixos.nixpc-glances
      self.modules.nixos.nixpcDisko
      self.modules.nixos.nixpcHardware
      self.modules.nixos.moonlight
      {
        networking.hostName = "nixpc";
        home-manager.users.radu = { pkgs, ... }: {
          imports = [ self.modules.homeManager.csharp ];
          home.packages = [ pkgs.discord ];
          # Both on workspace "1"; WezTerm first, so it takes the left side when tiled
          autostart.workspaceLayout = ''
            cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 20
            cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
          '';
        };
      }
    ];
  };
}

{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.modules.nixos.base
      {
        home-manager.users.root.imports = [
          self.modules.homeManager.base
          self.modules.homeManager.ai
          self.modules.homeManager.fish
          self.modules.homeManager.git
          self.modules.homeManager.nvim
          self.modules.homeManager.rust
          self.modules.homeManager.csharp
          self.modules.homeManager.tmux
        ];

        wsl.enable = true;
        wsl.interop.register = true;
        networking.hostName = "wsl";
        environment.sessionVariables.HOST_ICON = "󰖳";
        system.stateVersion = "26.05";

        # make /root accessible from native Windows via File Explorer
        users.users.root = {
          group = lib.mkForce "users";
          homeMode = "775";
        };
        system.activationScripts.rootHomePermissions = lib.stringAfter [ "users" ] ''
          chown root:users /root
          chmod 0775 /root
        '';

        # copies wezterm.lua from this repo to wezterm Windows config folder
        system.activationScripts.weztermCopy = ''
          WIN_USER=$(ls -d /mnt/c/Users/*/AppData | grep -v Default | head -n 1 | cut -d/ -f5)
          install -D ${self.outPath}/wezterm/wezterm.lua "/mnt/c/Users/$WIN_USER/.config/wezterm/wezterm.lua"
        '';
      }
    ];
  };
}

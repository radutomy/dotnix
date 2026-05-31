{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosConfigurations.orb = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      self.modules.nixos.base
      {
        home-manager.users.root.imports = with self.modules.homeManager; [
          base
          ai
          fish
          git
          nvim
          rust
          csharp
          tmux
        ];
      }
      (
        { modulesPath, ... }:
        {
          imports = [ "${modulesPath}/virtualisation/lxc-container.nix" ];

          environment.etc."resolv.conf".source = "/opt/orbstack-guest/etc/resolv.conf";
          networking.resolvconf.enable = false;
          environment.shellInit = ''
            . /opt/orbstack-guest/etc/profile-early
            . /opt/orbstack-guest/etc/profile-late
          '';

          systemd.services = {
            "systemd-udevd".serviceConfig.WatchdogSec = 0;
            "systemd-journald@".serviceConfig.WatchdogSec = 0;
            "systemd-journald".serviceConfig.WatchdogSec = 0;
            "systemd-hostnamed".serviceConfig.WatchdogSec = 0;
          };

          networking.hostName = "orb";
          environment.sessionVariables.HOST_ICON = "󰏖";
          services.openssh.enable = false; # the lxc-container profile enables it

          # make /root accessible from native macOS via Finder
          users.users.root = {
            group = lib.mkForce "users";
            homeMode = "775";
          };

          time.timeZone = "Europe/London";
          nix.settings.extra-platforms = [ "x86_64-linux" ];
          system.stateVersion = "25.11";

          # copies wezterm.lua from this repo to wezterm MacOS config folder
          system.activationScripts.weztermCopy = ''
            MAC_USER=$(ls /mnt/mac/Users | grep -v Shared | head -n 1)
            install -D ${self.outPath}/wezterm/wezterm.lua "/mnt/mac/Users/$MAC_USER/.config/wezterm/wezterm.lua"
          '';
        }
      )
    ];
  };
}

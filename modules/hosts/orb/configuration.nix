{ self, lib, ... }:
{
  flake.nixosModules.orb =
    { modulesPath, ... }:
    {
      environment.etc."resolv.conf".source = "/opt/orbstack-guest/etc/resolv.conf";
      environment.shellInit = ''
        . /opt/orbstack-guest/etc/profile-early
        . /opt/orbstack-guest/etc/profile-late
      '';

      imports = [
        "${modulesPath}/virtualisation/lxc-container.nix"
      ];

      systemd.services = {
        "systemd-udevd".serviceConfig.WatchdogSec = 0;
        "systemd-journald@".serviceConfig.WatchdogSec = 0;
        "systemd-journald".serviceConfig.WatchdogSec = 0;
        "systemd-hostnamed".serviceConfig.WatchdogSec = 0;
      };

      networking.hostName = "orb";
      services.openssh.enable = false;

      # make /root accessible from native macOS via Finder
      users.users.root = {
        group = lib.mkForce "users";
        homeMode = "775";
      };

      time.timeZone = "Europe/London";
      nix.settings.extra-platforms = [ "x86_64-linux" ];
      system.stateVersion = "25.11";

      programs.ssh.extraConfig = lib.mkAfter ''
        Host nas
          HostName 192.168.0.2
          User root
      '';

      # copies wezterm.lua from this repo to wezterm MacOS config folder
      system.activationScripts.weztermCopy = ''
        MAC_USER=$(ls /mnt/mac/Users | grep -v Shared | head -n 1)
        install -D ${self.outPath}/wezterm/wezterm.lua "/mnt/mac/Users/$MAC_USER/.config/wezterm/wezterm.lua"
      '';
    };
}

_: {
  flake.modules.nixos.nixpc-config = { lib, pkgs, ... }: {
    networking.hostName = "nixpc";
    home-manager.users.radu = {
      tmux.layout = "desktop";
      # Both on workspace "1"; WezTerm first, so it takes the left side when tiled
      autostart.workspaceLayout = ''
        cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 20
        cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
      '';
    };

    # Start the login right away. The default "idle" waits for other boot jobs
    systemd.services.greetd.serviceConfig.Type = lib.mkForce "exec";

    # TODO: (added 2026-11) the Sky hub blocks a port for 4-8s after link up (STP), so the disk unlock below uses a fixed boot address, retries the NAS with curl, and needs device-lan so NetworkManager takes over. With a new router or a dumb switch, try plain DHCP in 10-lan and drop the curl retry and device-lan
    networking.networkmanager.settings.device-lan = {
      match-device = "interface-name:enp14s0";
      keep-configuration = false;
    };

    boot.initrd = {
      availableKernelModules = [ "r8169" ];
      systemd.network = {
        enable = true;
        networks."10-lan" = {
          matchConfig.Name = "enp14s0";
          address = [ "192.168.0.3/24" ];
        };
      };
      systemd.services.cryptsetup-clevis-cryptroot.serviceConfig.ExecStartPre = toString [
        "${lib.getExe pkgs.curl} --silent --output /dev/null"
        "--retry 100 --retry-delay 0.2 --retry-all-errors --retry-max-time 15"
        "--connect-timeout 0.3"
        "http://192.168.0.2:7654/adv"
      ];
      clevis = {
        enable = true;
        devices.cryptroot.secretFile = ../../../secrets/cryptroot.jwe;
      };
    };
  };
}

_: {
  flake.modules.nixos.nixpc-config = {
    networking.hostName = "nixpc";
    home-manager.users.radu = {
      tmux.layout = "desktop";
      # Both on workspace "1"; WezTerm first, so it takes the left side when tiled
      autostart.workspaceLayout = ''
        cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 20
        cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
      '';
    };

    boot.initrd = {
      availableKernelModules = [ "r8169" ];
      network.flushBeforeStage2 = true;
      systemd.network = {
        enable = true;
        wait-online.timeout = 15;
        networks."10-lan" = {
          matchConfig.Driver = "r8169";
          address = [ "192.168.0.3/24" ];
        };
      };
      clevis = {
        enable = true;
        useTang = true;
        devices.cryptroot.secretFile = ../../../secrets/cryptroot.jwe;
      };
    };
  };
}

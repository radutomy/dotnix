_: {
  flake.modules.nixos.nixpc-config = {
    networking.hostName = "nixpc";
    home-manager.users.radu = { pkgs, ... }: {
      home.packages = [ pkgs.discord ];
      tmux.layout = "desktop";
      # Both on workspace "1"; WezTerm first, so it takes the left side when tiled
      autostart.workspaceLayout = ''
        cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 20
        cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
      '';
    };
  };
}

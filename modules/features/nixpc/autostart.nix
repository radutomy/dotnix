_: {
  # Both on workspace "1"; WezTerm first, so it takes the left side when tiled
  flake.modules.homeManager.nixpc-autostart.autostart.workspaceLayout = ''
    cos-cli move -a org.wezfurlong.wezterm -w 0 -g 0 -o 0 --wait 20
    cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
  '';
}

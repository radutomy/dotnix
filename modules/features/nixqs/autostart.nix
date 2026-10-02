_: {
  flake.modules.homeManager.nixqs-autostart.autostart.workspaceLayout = ''
    cos-cli move -a firefox -w 0 -g 0 -o 0 --wait 20
    cos-cli state -a firefox --maximize
    cos-cli move -a org.wezfurlong.wezterm -w 1 -g 0 -o 0 --wait 20
    cos-cli state -a org.wezfurlong.wezterm --maximize
  '';
}

_: {
  flake.modules.nixos.hwshared = {
    services.fwupd.enable = true;

    # Caps Lock is disabled and repurposed as a nav layer instead:
    # caps+left/right/up/down = home/end/page up/down.
    # caps+h/j/k/l = left/down/up/right arrows.
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          main.capslock = "layer(nav)";
          nav = {
            left = "home";
            right = "end";
            up = "pageup";
            down = "pagedown";
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          };
        };
      };
    };
  };
}

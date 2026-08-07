_: {
  flake.modules.nixos.hwshared = {
    services.fwupd.enable = true;

    # Caps Lock is disabled and repurposed as a nav layer instead:
    # caps+left/right/up/down = home/end/page up/down.
    # caps+h/l = home/end, caps+j/k = word left/right (like ctrl+left/right).
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
            j = "home";
            h = "C-left";
            l = "C-right";
            k = "end";
          };
        };
      };
    };
  };
}

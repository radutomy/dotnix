_: {
  flake.modules.nixos.hwshared = {
    services.fwupd.enable = true;

    # Caps Lock is disabled and repurposed as a nav layer instead:
    # caps+left/right/up/down and caps+hjkl both do home/end/page up/down.
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
            h = "home";
            j = "pagedown";
            k = "pageup";
            l = "end";
          };
        };
      };
    };
  };
}

_: {
  flake.modules.nixos.hwshared = {
    services.fwupd.enable = true;

    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # Caps Lock is disabled and repurposed as a nav layer instead:
    # caps+left/right/up/down = home/end/page up/down.
    # caps+h/j/k/l = left/down/up/right arrows.
    # caps+h twice quickly = Home, caps+l twice quickly = End
    # (kanata's tap-dance; keyd doesn't support double-tap detection,
    # hence kanata over keyd).
    services.kanata = {
      enable = true;
      keyboards.default.config = ''
        (defsrc
          caps
          left right up down
          h j k l
        )

        (deflayermap (base)
          caps (layer-while-held nav)
          left left
          right right
          up up
          down down
          h h
          j j
          k k
          l l
        )

        (deflayermap (nav)
          caps _
          left home
          right end
          up pgup
          down pgdn
          h (tap-dance-eager 180 (left home))
          j down
          k up
          l (tap-dance-eager 180 (right end))
        )
      '';
    };
  };
}

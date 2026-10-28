_: {
  flake.modules.nixos.hardware = { config, lib, ... }: {
    services.fwupd.enable = true;
    systemd.services.kanata-default.serviceConfig.Restart = "on-failure";
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    services.kanata = {
      enable = true;
      keyboards.default.config = ''
        (defsrc)

        (deflayermap (base)
          caps (layer-while-held nav)
          ralt (layer-while-held media)
          lctl (multi lctl (layer-while-held ctl))
        )

        (deflayermap (ctl)
          w bspc
        )

        (deflayermap (nav)
          left home
          right end
          up pgup
          down pgdn
          h left
          j down
          k up
          l right
          esc grv
          e home
          f end
          1 f1  2 f2  3 f3  4 f4  5 f5  6 f6
          7 f7  8 f8  9 f9  0 f10  - f11  = f12
          bspc del
          bksl nubs
          rsft pgup
          rmet home
          comp pgdn
          rctl end
        )

        (deflayermap (media)
          bspc volu
          bksl voldwn
          ret pp
          comm prev
          . next
          rsft mute
          up mute
          esc power
          ${lib.optionalString (config.networking.hostName == "nixpc") "left f24"}
        )
      '';
    };
  };
}

_: {
  flake.modules.nixos.cosmic = { pkgs, ... }: {
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-initial-setup
    ];

    services = {
      desktopManager.cosmic = {
        enable = true;
        showExcludedPkgsWarning = false;
      };
      displayManager.cosmic-greeter.enable = true;

      pipewire.wireplumber.extraConfig."51-audio-devices" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "alsa_card.pci-0000_03_00.1"; }
              { "device.name" = "alsa_card.pci-0000_12_00.1"; }
              { "device.name" = "alsa_card.usb-SJ-180517-N_1080P_Webcam-02"; }
            ];
            actions.update-props."device.disabled" = true;
          }
          {
            matches = [
              { "node.name" = "alsa_output.usb-Generic_USB_Audio-00.HiFi__Headphones__sink"; }
              { "node.name" = "alsa_input.usb-Generic_USB_Audio-00.HiFi__Line__source"; }
              { "node.name" = "alsa_input.usb-FiiO_DigiHug_USB_Audio-01.analog-stereo"; }
            ];
            actions.update-props."node.disabled" = true;
          }
        ];
      };

      # do not allow applications to prompt for keyring
      gnome.gnome-keyring.enable = false;
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "org.wezfurlong.wezterm.desktop" ];
    };
  };

  flake.modules.homeManager.cosmic =
    { config, pkgs, ... }:
    let
      desktopEntry = package: name: "${package}/share/applications/${name}.desktop";
    in
    {
      xdg = {
        autostart = {
          enable = true;
          entries = [
            #(desktopEntry pkgs.discord "discord")
            #(desktopEntry pkgs.steam "steam")
            (desktopEntry config.programs.firefox.package "firefox")
            (desktopEntry pkgs.wezterm "org.wezfurlong.wezterm")
          ];
        };

        configFile."cosmic".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/cosmic";

        stateFile."cosmic-comp/outputs.ron".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/cosmic/state/outputs.ron";
      };
    };
}

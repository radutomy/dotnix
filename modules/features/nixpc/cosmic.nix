_: {
  flake.modules.nixos.cosmic = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.symbols-only
    ];

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-initial-setup
    ];

    services = {
      desktopManager.cosmic = {
        enable = true;
        showExcludedPkgsWarning = false;
      };
      displayManager.cosmic-greeter.enable = true;

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
      home.packages = with pkgs; [
        cosmic-ext-applet-weather
        cosmic-ext-applet-minimon
      ];

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

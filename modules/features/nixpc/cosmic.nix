_: {
  flake.modules.nixos.cosmic = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.symbols-only
    ];

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-initial-setup
    ];

    # use wayland where possible
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
    {
      home.packages = with pkgs; [
        cosmic-ext-applet-weather
        cosmic-ext-applet-minimon
      ];

      xdg.configFile."cosmic".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/cosmic";
    };
}

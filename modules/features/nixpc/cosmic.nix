_: {
  flake.modules.nixos.cosmic = { pkgs, ... }: {
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-initial-setup
      cosmic-term
    ];

    services = {
      desktopManager.cosmic = {
        enable = true;
        showExcludedPkgsWarning = false;
      };
      displayManager.cosmic-greeter.enable = true;
    };

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "org.wezfurlong.wezterm.desktop" ];
    };
  };

  flake.modules.homeManager.cosmic = { config, ... }: {
    xdg = {
      configFile."cosmic".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/cosmic";

      stateFile."cosmic-comp/outputs.ron".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/cosmic/state/outputs.ron";
    };
  };
}

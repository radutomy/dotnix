{ self, inputs, ... }:
let
  user = "radu";
  host = "nixpc";

  home = { config, pkgs, ... }: {
    imports = with self.modules.homeManager; [
      base
      ai
      fish
      git
      nvim
      rust
      tmux
      cosmic
    ];

    home.packages = with pkgs; [
      cosmic-ext-applet-sysinfo
      cosmic-ext-applet-weather
      firefox
      wezterm
    ];

    xdg.configFile."wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";
  };

  nixos = _: {
    networking = {
      hostName = host;
      networkmanager.enable = true;
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    services.displayManager.autoLogin = {
      enable = true;
      inherit user;
    };

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };

    security.sudo.extraConfig = "Defaults timestamp_timeout=-1";
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    system.stateVersion = "26.05";
  };
in
{
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixpcHardware
      self.modules.nixos.cosmic
      self.modules.nixos.coolercontrol
      nixos
      {
        home-manager.users.${user} = home;
      }
    ];
  };
}

_: {
  flake.modules.nixos.nixqs-config = { config, ... }: {
    networking = {
      hostName = "nixqs";
      networkmanager.enable = true;
      firewall.trustedInterfaces = [ "enp131s0" ];
    };

    environment.sessionVariables.SSH_AUTH_SOCK = "${config.users.users.radu.home}/.bitwarden-ssh-agent.sock";

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    # Quiet boot: suppress the systemd unit spam and harmless kernel
    # warnings (e.g. usbhid on control-only HID interfaces) before the
    # LUKS PIN prompt.
    boot.consoleLogLevel = 3;
    boot.kernelParams = [ "quiet" ];

    services.displayManager.autoLogin = {
      enable = true;
      user = "radu";
    };

    services.tailscale.enable = true;

    users.mutableUsers = false;
    users.users.radu = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$1wLAffWwSDgcdAyBLVOe3/$JIs2iEJPfTzemMx/EBvfWsJo.MswBJH/ekhyxmANKP9";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };

    # Never ask for a sudo password, and suppress sudo's introductory lecture.
    security.sudo.wheelNeedsPassword = false;
    security.sudo.extraConfig = "Defaults lecture=never";
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    system.stateVersion = "26.05";

    home-manager.users.radu =
      { config, ... }:
      {
        xdg.userDirs = {
          enable = true;
          createDirectories = false;

          desktop = null;
          documents = null;
          music = null;
          pictures = null;
          projects = null;
          publicShare = null;
          templates = null;
          videos = null;
        };

        xdg.configFile."wezterm".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";
      };
  };
}

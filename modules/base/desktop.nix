# Shared by every NixOS host with a graphical desktop (nixqs, nixpc).
{ self, ... }: {
  flake.modules.nixos.desktop = { config, ... }: {
    imports = [
      self.modules.nixos.cosmic
      self.modules.nixos.steam
      self.modules.nixos.hwshared
    ];

    networking.networkmanager.enable = true;
    services.tailscale.enable = true;

    environment.sessionVariables.SSH_AUTH_SOCK = "${config.users.users.radu.home}/.bitwarden-ssh-agent.sock";

    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
      };

      # Quiet boot: hide systemd unit spam and harmless kernel warnings
      consoleLogLevel = 3;
      kernelParams = [ "quiet" ];
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "radu";
    };

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
  };

  flake.modules.homeManager.desktop = { config, pkgs, ... }: {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.ai
      self.modules.homeManager.fish
      self.modules.homeManager.git
      self.modules.homeManager.nvim
      self.modules.homeManager.rust
      self.modules.homeManager.tmux
      self.modules.homeManager.cosmic
      self.modules.homeManager.firefox
    ];

    home.packages = with pkgs; [
      vscodium
      wezterm
      simplenote
      chromium
      spotify
      bitwarden-desktop
      signal-desktop
      cheese
      popsicle
    ];

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
}

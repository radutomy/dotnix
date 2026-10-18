# Shared by every NixOS host with a graphical desktop (nixqs, nixpc, nixmi).
{ self, ... }:
let
  nixosImports = [
    self.modules.nixos.base
    self.modules.nixos.sshc
    self.modules.nixos.preservation
    self.modules.nixos.work
    self.modules.nixos.cosmic
    self.modules.nixos.steam
    self.modules.nixos.hardware
    self.modules.nixos.distrobox
  ];

  homeImports = [
    self.modules.homeManager.base
    self.modules.homeManager.rust
    self.modules.homeManager.cosmic
    self.modules.homeManager.firefox
    self.modules.homeManager.autostart
  ];

  homePackages =
    pkgs: with pkgs; [
      wezterm
      chromium
      spotify
      bitwarden-desktop
      signal-desktop
      cheese
      popsicle
    ];
in
{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    imports = nixosImports;
    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.enableRedistributableFirmware = true;
    home-manager.users.radu.imports = [ self.modules.homeManager.desktop ];

    networking.networkmanager.enable = true;
    services = {
      # Backs COSMIC's power menu instead of system76-power, which the COSMIC module enables otherwise
      power-profiles-daemon.enable = true;
      # Never sleep on the charger, even with the lid closed
      logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
      displayManager.autoLogin = {
        enable = true;
        user = "radu";
      };
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
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
      binfmt.emulatedSystems = [ "aarch64-linux" ];
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
    i18n.defaultLocale = "en_GB.UTF-8";
  };

  flake.modules.homeManager.desktop = { config, pkgs, ... }: {
    imports = homeImports;
    home.packages = homePackages pkgs;

    xdg.userDirs = {
      enable = true;
      createDirectories = false;

      desktop = null;
      documents = null;
      music = null;
      pictures = null;
      projects = null;
      publicShare = "/run/user/1000/gvfs/sftp:host=nas,user=root/gdrive";
      templates = null;
      videos = null;
    };

    xdg.configFile."wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";
  };
}

_: {
  flake.nixosModules.nas =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "nas";
      networking.networkmanager.enable = true;

      time.timeZone = "Europe/London";

      i18n.defaultLocale = "en_GB.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_NUMERIC = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };

      services.xserver.xkb = {
        layout = "gb";
        variant = "";
      };
      console.keyMap = "uk";

      users.users.radu = {
        isNormalUser = true;
        description = "radu";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
      ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      environment.sessionVariables.HOST_ICON = "󰒍";
      programs.tmux.enable = true;
      # Use the NAS tmux config as ~/.config/tmux/tmux.conf.
      systemd.tmpfiles.rules = [
        "r! %h/.config/tmux - - - - -"
        "d %h/.config/tmux 0755 - - - -"
        "L+ %h/.config/tmux/tmux.conf - - - - %h/dotnix/tmux/tmux.nas.conf"
      ];

      system.stateVersion = "25.11";
    };
}

{ inputs, ... }:
{
  flake.modules.nixos.nas-config =
    { pkgs, ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];

      age.identityPaths = [ "/root/.ssh/id_ed25519" ];

      boot = {
        supportedFilesystems = [ "zfs" ];
        zfs.forceImportRoot = false;
        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
        };
      };

      users = {
        mutableUsers = false;
        users.root = {
          hashedPassword = "$y$j9T$oUA03zdU/rjx/AJ.Zluez.$nR2BCbxAW/q6GegPqbrsb4jZNFBnIdbDHqTm0hOA7y/";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
          ];
        };
      };

      services = {
        openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };

        zfs.autoScrub = {
          enable = true;
          pools = [ "tank" ];
          interval = "monthly";
        };

        udev.extraRules = ''
          ACTION=="add|change", SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", RUN+="${pkgs.nvme-cli}/bin/nvme set-feature /dev/%k -f 0x02 -V 2"
        '';
      };

      networking = {
        # Stable 32-bit ZFS host ID used for pool import safety.
        hostId = "6e617330";
        hostName = "nas";
        useDHCP = false;

        interfaces.enp7s0.ipv4.addresses = [
          {
            address = "192.168.0.2";
            prefixLength = 24;
          }
        ];
        defaultGateway = "192.168.0.1";

        nameservers = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };

      environment.sessionVariables.HOST_ICON = "󰒍";
      system.stateVersion = "26.05";
      time.timeZone = "Europe/London";

      environment.systemPackages = with pkgs; [
        nvme-cli
        smartmontools
        psutils
      ];

      # Nested tmux: pane-aware Alt+h/l on the inner session.
      programs.tmux = {
        enable = true;
        extraConfig = ''
          bind -n M-h if -F "#{pane_at_left}" "prev" "selectp -L"
          bind -n M-j selectp -D
          bind -n M-k selectp -U
          bind -n M-l if -F "#{pane_at_right}" "next" "selectp -R"
        '';
      };
    };
}

{ inputs, ... }: {
  flake.modules.nixos.nas-config = { pkgs, ... }: {
    imports = [ inputs.agenix.nixosModules.default ];

    age.identityPaths = [ "/var/lib/agenix/nas.agekey" ];

    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs.forceImportRoot = false;
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };
    };

    users.mutableUsers = false;
    users.users.root.hashedPassword = "$y$j9T$oUA03zdU/rjx/AJ.Zluez.$nR2BCbxAW/q6GegPqbrsb4jZNFBnIdbDHqTm0hOA7y/";

    services = {
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

    environment.systemPackages = with pkgs; [
      nvme-cli
      smartmontools
      psutils
    ];
  };
}

{ inputs, ... }: {
  flake.modules.nixos.nixqsDisko = {
    imports = [ inputs.disko.nixosModules.disko ];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    zramSwap.enable = true;
    boot.kernelParams = [ "nohibernate" ];

    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };

    disko.devices.disk.main = {
      device = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [
                "-n"
                "BOOT"
              ];
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              askPassword = true;
              settings.allowDiscards = true;

              content = {
                type = "btrfs";
                preCreateHook = ''
                  mkfs.btrfs -f "$device"
                  udevadm trigger --settle --name-match="$device"
                '';
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "noatime"
                      "compress=zstd"
                    ];
                  };
                  "/persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "noatime"
                      "compress=zstd"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

{ inputs, ... }:
{
  flake.modules.nixos.nixpcDisko = {
    imports = [ inputs.disko.nixosModules.disko ];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };

    disko.devices.disk.main = {
      device = "/dev/disk/by-path/pci-0000:07:00.0-nvme-1";
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
          swap = {
            size = "64G";
            content = {
              type = "swap";
              extraArgs = [
                "-L"
                "swap"
              ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              #extraArgs = [ "-f" ];
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
}

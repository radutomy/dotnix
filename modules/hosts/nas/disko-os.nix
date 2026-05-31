{ inputs, ... }:
{
  flake.modules.nixos.nasOSDisko =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      disko.devices.disk = {

        os = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:05:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                label = "disk-main-ESP";
                name = "ESP";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };
              };

              swap = {
                label = "disk-main-swap";
                name = "swap";
                size = "16G";
                content = {
                  type = "swap";
                  extraArgs = [
                    "-L"
                    "swap"
                  ];
                };
              };

              "zz-root" = {
                label = "disk-main-root";
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = [
                    "-L"
                    "root"
                  ];
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };

      # Mount the existing ZFS data pool into the OS at /tank
      fileSystems."/tank" = {
        device = lib.mkDefault "tank";
        fsType = lib.mkDefault "zfs";
        options = lib.mkDefault [
          "defaults"
          "zfsutil"
        ];
      };
    };
}

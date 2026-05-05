_: {
  flake.nixosModules.nasDataDisko =
    { lib, ... }:
    {
      disko.devices.disk = {

        data1 = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };

        data2 = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:02:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };

        data3 = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:03:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };

        data4 = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };

      disko.devices.zpool.tank = {
        type = "zpool";
        mode = "raidz1";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          xattr = "sa";
        };
        mountpoint = "/tank";
      };
    };
}

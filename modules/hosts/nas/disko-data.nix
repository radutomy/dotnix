{ inputs, ... }:
let
  disks = {
    data1 = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
    data2 = "/dev/disk/by-path/pci-0000:02:00.0-nvme-1";
    data3 = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1";
    data4 = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
  };
in
{
  flake.modules.nixos.nas-data-disko = { lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk = lib.mapAttrs (_: device: {
      device = lib.mkDefault device;
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
    }) disks;

    disko.devices.zpool.tank = {
      type = "zpool";
      mode = "raidz1";
      mountpoint = "/tank";
      rootFsOptions = {
        acltype = "posixacl";
        atime = "off";
        compression = "zstd";
        xattr = "sa";
      };

      datasets.drive = {
        type = "zfs_fs";
        mountpoint = "/drive";
        options = {
          copies = "3";
          quota = "100G";
        };
      };
    };
  };
}

{ inputs, ... }: {
  flake.modules.nixos.nixpiDisko = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.nixpi = {
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          firmware = {
            size = "512M";
            type = "0700";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/firmware";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            attributes = [ 2 ];
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}

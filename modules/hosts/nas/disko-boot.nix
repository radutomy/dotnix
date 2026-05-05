_: {
  flake.nixosModules.nasBootDisko =
    { lib, ... }:
    {
      disko.devices.disk = {
        main = {
          device = lib.mkDefault "/dev/disk/by-path/pci-0000:05:00.0-nvme-1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
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
    };
}

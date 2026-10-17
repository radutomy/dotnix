{ self, inputs, ... }: {
  flake.nixosConfigurations.liveUsb = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
      "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
      self.modules.nixos.sshd
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      ({ config, lib, ... }: {
        isoImage = {
          makeEfiBootable = true;
          makeUsbBootable = true;
        };

        fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
        swapDevices = lib.mkImageMediaOverride [ ];

        networking.hostName = "live-usb";
        networking.useDHCP = true;

        boot.loader.timeout = lib.mkForce 1;
        boot.zfs.forceImportRoot = false;

        system.stateVersion = "26.05";
      })
    ];
  };

  perSystem = { pkgs, ... }: {
    apps.liveUsb.program = pkgs.writeShellApplication {
      name = "copy-live-usb-iso";
      text = ''
        cp ${self.nixosConfigurations.liveUsb.config.system.build.isoImage}/iso/*.iso /tmp/live-usb.iso
        echo /tmp/live-usb.iso
      '';
    };
  };
}

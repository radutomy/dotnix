{ self, inputs, ... }:
{
  flake.nixosConfigurations.liveUsb = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
      "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"

      (
        { config, lib, ... }:
        {
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

          services.openssh = {
            enable = true;
            openFirewall = true;
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              PermitRootLogin = "prohibit-password";
            };
          };

          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
          ];

          system.stateVersion = "25.11";
        }
      )
    ];
  };

  perSystem =
    { pkgs, ... }:
    {
      apps.liveUsb.program = pkgs.writeShellApplication {
        name = "copy-live-usb-iso";
        text = ''
          cp ${self.nixosConfigurations.liveUsb.config.system.build.isoImage}/iso/*.iso /tmp/live-usb.iso
          echo /tmp/live-usb.iso
        '';
      };
    };
}

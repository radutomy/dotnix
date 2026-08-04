{ inputs, ... }: {
  flake.modules.nixos.nixqsPreservation = {
    imports = [ inputs.preservation.nixosModules.default ];

    preservation.enable = true;
    preservation.preserveAt."/persistent" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/systemd";
          inInitrd = true;
        }
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/log"
      ];

      users.radu.directories = [
        ".ssh"
        ".cargo"
        ".cache/nix"
        ".cache/spotify"
        ".config"
        ".local/state"
        ".local/share"

        # User Data
        "dotnix"
        "Downloads"
        "src"
      ];
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}

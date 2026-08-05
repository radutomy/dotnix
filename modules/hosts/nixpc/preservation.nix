{ inputs, ... }: {
  flake.modules.nixos.nixpcPreservation = {
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
        ".config/Bitwarden"
        ".config/claude"
        ".config/cosmic"
        ".config/codex"
        ".config/flameshot"
        ".config/mozilla"
        ".config/discord"
        ".config/Simplenote"
        ".config/spotify"
        ".config/sunshine"
        ".config/YouTube Music"
        ".local/state/cosmic-comp"
        ".local/state/nvim"
        ".local/share/fish"
        ".local/share/nvim"
        ".local/share/Steam"
        ".local/share/zoxide"

        # User Data
        "dotnix"
        "Downloads"
        "src"
      ];
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}

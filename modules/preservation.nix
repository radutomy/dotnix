{ inputs, ... }: {
  flake.modules.nixos.preservation = {
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
        "/var/lib/tailscale"
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
        ".config/copilot"
        ".config/mozilla"
        ".config/gh"
        ".config/Signal"
        ".config/spotify"
        ".local/state/cosmic-comp"
        ".local/state/nvim"
        ".local/state/wireplumber"
        ".local/share/fish"
        ".local/share/nvim"
        ".local/share/zoxide"
        ".vite-plugin-mkcert"

        # User Data
        "dotnix"
        "src"
        {
          directory = "Downloads";
          mountOptions = [ "x-gvfs-hide" ]; # hide it from COSMIC Files
        }
      ];
    };

    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}

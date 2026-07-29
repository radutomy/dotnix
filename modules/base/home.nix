# Shared Home Manager configuration.
{
  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home = {
        stateVersion = "26.05";

        packages = with pkgs; [
          nh
          lsd
          jq
          bat
          age
          just
          zip
          unzip
          python3
          wget
          gh
          ripgrep
          fd
          lsof
          sqlite
          shellcheck
          yq-go
          dnsutils
        ];

        shellAliases = {
          ls = "lsd --group-dirs=first";
          ll = "lsd -lah --group-dirs=first";
          l = "lsd -A --group-dirs=first";
          cat = "bat --style=plain";
          p = "python";
          gg = "lazygit";
          cx = "codex";
          cxr = "codex resume";
          cc = "claude";
          ccr = "claude --resume";
        };
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
            ConnectTimeout = 10;
          };
          nas = {
            HostName = "192.168.0.2";
            User = "root";
            ForwardAgent = true;
          };
        };
      };

      # Bitwarden's SSH agent replaces the old file-based identity.
      home.activation.removeLegacySshKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -f "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519.bak"
      '';

      nixpkgs.config.allowUnfree = true;
      nix.package = lib.mkDefault pkgs.nix;
      nix.settings = {
        warn-dirty = false;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
}

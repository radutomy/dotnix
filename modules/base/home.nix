# Shared Home Manager configuration.
{
  flake.modules.homeManager.base =
    { pkgs, lib, ... }:
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
          python3
          yazi
          wget
        ];

        shellAliases = {
          ls = "lsd --group-dirs=first";
          ll = "lsd -lah --group-dirs=first";
          l = "lsd -A --group-dirs=first";
          cat = "bat --style=plain";
          p = "python";
          gg = "lazygit";
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
          };
        };
      };

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

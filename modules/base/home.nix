# what every home gets, NixOS or not: cli tools, aliases, nix config
let
  dotnix = "$HOME/dotnix";
in
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

          # on non-NixOS machines ns/nu rebuild just the home; on NixOS hosts
          # the higher-priority definitions in nixos.nix win
          ns = lib.mkDefault "nh home switch ${dotnix}";
          nu = lib.mkDefault "nh home switch ${dotnix} --update && git -C ${dotnix} commit -m 'flake.lock' -- flake.lock && git -C ${dotnix} push";
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
      # home-manager generates the user nix.conf with this nix
      # (on hosts the home-manager module overrides it with the system one)
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

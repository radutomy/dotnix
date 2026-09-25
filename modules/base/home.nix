# Shared Home Manager configuration.
{ inputs, ... }:
{
  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      home = {
        stateVersion = "26.05";

        packages = with pkgs; [
          nh
          lsd
          age
          just
          zip
          unzip
          python3
          wget
          lsof
          sqlite
          yq-go
          xxd
          dnsutils
          btop
          fastfetch
          yazi
          geekbench
          witr

          # Mostly used by the AI tool
          ripgrep
          fd
          jq
          shellcheck
          gh
          poppler-utils
          ast-grep
          tokei
          hyperfine
          nix-tree
        ];

        shellAliases = {
          ls = "lsd --group-dirs=first";
          ll = "lsd -lah --group-dirs=first";
          l = "lsd -A --group-dirs=first";
          cat = "bat --style=plain";
          p = "python";
          gg = "lazygit";
          # cx = "codex --profile nix";
          # cxr = "codex --profile nix resume";
          cx = "codex";
          cxr = "codex resume";
          cc = "claude";
          ccr = "claude --resume";
          copilot = "copilot --allow-all";
          co = "copilot --allow-all";
        };
      };

      programs = {
        # `, <command>` runs any nixpkgs command without installing it
        nix-index.enable = true;
        nix-index-database.comma.enable = true;

        bat = {
          enable = true;
          config.theme = "Visual Studio Dark+";
        };

        ssh = {
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

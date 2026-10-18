# Shared by every machine
{ self, inputs, ... }:
let
  homeImports = with self.modules.homeManager; [
    inputs.nix-index-database.homeModules.nix-index
    ai
    fish
    git
    nvim
    ssh
    tmux
  ];

  homePackages =
    pkgs: with pkgs; [
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
      witr

      # Mostly used by the AI tool
      ripgrep
      fd
      jq
      bc
      shellcheck
      gh
      poppler-utils
      ast-grep
      tokei
      hyperfine
      nix-tree
    ];
in
{
  flake.modules.nixos.base = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    nix.channel.enable = false;
    programs.nh.clean = {
      enable = true;
      extraArgs = "--keep 10 --no-gcroots";
    };
    services.tailscale.enable = true;
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
    time.timeZone = "Europe/London";
    system.stateVersion = "26.05";
  };

  flake.modules.homeManager.base = { pkgs, ... }: {
    imports = homeImports;

    home = {
      packages = homePackages pkgs;
      stateVersion = "26.05";

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
        copilot = "copilot --allow-all";
        co = "copilot --allow-all --continue";
      };
    };

    programs = {
      # , <command> runs any nixpkgs command without installing it
      nix-index.enable = true;
      nix-index-database.comma.enable = true;

      bat = {
        enable = true;
        config.theme = "Visual Studio Dark+";
      };
    };
  };
}

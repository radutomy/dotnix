{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    disko.url = "github:nix-community/disko";
    preservation.url = "github:nix-community/preservation";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    agenix.url = "github:ryantm/agenix";

    # Used by sunshine.nix and cos-cli.nix; remove it if both modules are removed.
    cos-cli.url = "github:estin/cos-cli";
    cosmic-process-applet.url = "github:radutomy/cosmic-process-applet";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}

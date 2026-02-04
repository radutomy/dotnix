{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    mkHome = { system, username }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      extraSpecialArgs = {
        inherit username;
        pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      };
      modules = [ ./home.nix ./modules/git.nix ./modules/zsh.nix ./modules/helix.nix ./modules/rust.nix ];
    };
  in {
    homeConfigurations = {
      "root@nixos" = mkHome { system = "x86_64-linux"; username = "root"; };
      # Add more machines here:
      # "radu@macbook" = mkHome { system = "aarch64-darwin"; username = "radu"; };
    };
  };
}

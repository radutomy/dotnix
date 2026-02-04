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
      modules = [ ./home.nix ./git/config.nix ./zsh/config.nix ./helix/config.nix ./rust/config.nix ];
    };
  in {
    homeConfigurations = {
      "root@nixos" = mkHome { system = "x86_64-linux"; username = "root"; };
    };
  };
}

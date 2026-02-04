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
    mkHome = { system, username, host }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      extraSpecialArgs = {
        inherit username;
        pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      };
      modules = [
        ./home.nix
        ./hosts/${host}/default.nix
      ];
    };
  in {
    homeConfigurations = {
      "radu@macbook"  = mkHome { system = "aarch64-darwin"; username = "radu"; host = "macbook"; };
      "radu@desktop"  = mkHome { system = "x86_64-linux";   username = "radu"; host = "desktop"; };
      "root@nas"      = mkHome { system = "x86_64-linux";   username = "root"; host = "nas"; };
      # Alias for testing
      "root@nixos"    = mkHome { system = "x86_64-linux";   username = "root"; host = "desktop"; };
    };
  };
}

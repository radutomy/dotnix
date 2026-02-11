{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      mkHome =
        {
          system,
          username,
          host,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit username;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./home.nix
            ./hosts/${host}/default.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            /etc/nixos/configuration.nix
            ./hosts/system.nix
          ];
        };
        nas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            /etc/nixos/configuration.nix
            ./hosts/system.nix
          ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            /etc/nixos/configuration.nix
            ./hosts/system.nix
          ];
        };
      };

      homeConfigurations = {
        "root@nas" = mkHome {
          system = "x86_64-linux";
          username = "root";
          host = "nas";
        };
        # OrbStack VM (aarch64)
        "root@nixos" = mkHome {
          system = "aarch64-linux";
          username = "root";
          host = "vm";
        };
        # WSL (x86_64) — "wsl" is a placeholder hostname
        "root@wsl" = mkHome {
          system = "x86_64-linux";
          username = "root";
          host = "vm";
        };
      };
    };
}

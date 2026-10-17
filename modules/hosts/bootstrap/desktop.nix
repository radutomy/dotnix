# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#<nixpc|nixqs|nixmi> -- <disk>
let
  disks = {
    nixpc = "nixpc";
    nixqs = "main";
    nixmi = "nixmi";
  };
in
{
  perSystem = { pkgs, lib, ... }: {
    apps = lib.mapAttrs (host: disk: {
      program = pkgs.writeShellApplication {
        name = host;
        runtimeInputs = with pkgs; [
          git
          disko
        ];
        text = ''
          if [ "$EUID" -eq 0 ]; then
            echo "Run ${host} without sudo"
            exit 1
          fi

          if [ "$#" -ne 1 ] || [ ! -b "$1" ]; then
            echo "Usage: ${host} <disk>" >&2
            echo "Find the disk name with: lsblk -pdo NAME,SIZE,MODEL" >&2
            exit 2
          fi

          sudo mount -o remount,size=26G /nix/.rw-store

          target=$(mktemp -d)

          git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix "$target/dotnix"

          sudo disko-install \
            --flake "path:$target/dotnix#${host}" \
            --disk ${disk} "$1" \
            --extra-files "$target" /persistent/home/radu
        '';
      };
    }) disks;
  };
}

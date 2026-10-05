# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#nixmi -- <disk>
_: {
  perSystem = { pkgs, ... }: {
    apps.nixmi.program = pkgs.writeShellApplication {
      name = "nixmi";
      runtimeInputs = with pkgs; [
        git
        disko
        util-linux
      ];
      text = ''
        if [ "$EUID" -eq 0 ]; then
          echo "Run nixmi without sudo"
          exit 1
        fi

        if [ "$#" -ne 1 ] || [ ! -b "$1" ]; then
          echo "Usage: nixmi <disk>" >&2
          echo "Find the disk name with: lsblk -pdo NAME,SIZE,MODEL" >&2
          exit 2
        fi

        sudo mount -o remount,size=26G /nix/.rw-store

        target=$(mktemp -d)

        git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix "$target/dotnix"

        sudo disko-install \
          --flake "path:$target/dotnix#nixmi" \
          --disk nixmi "$1" \
          --extra-files "$target" /persistent/home/radu
      '';
    };
  };
}

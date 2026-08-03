# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#nixqs -- <disk>
_: {
  perSystem = { pkgs, ... }: {
    apps.nixqs.program = pkgs.writeShellApplication {
      name = "nixqs";
      runtimeInputs = with pkgs; [
        git
        disko
      ];
      text = ''
        if [ "$EUID" -eq 0 ]; then
          echo "Run nixqs without sudo"
          exit 1
        fi

        if [ "$#" -ne 1 ] || [ ! -b "$1" ]; then
          echo "Usage: nixqs <disk>" >&2
          echo "Find the disk name with: lsblk -pdo NAME,SIZE,MODEL" >&2
          exit 2
        fi

        target=$(mktemp -d)

        git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix "$target/dotnix"

        sudo disko-install \
          --flake "path:$target/dotnix#nixqs" \
          --disk main "$1" \
          --extra-files "$target" /persistent/home/radu
      '';
    };
  };
}

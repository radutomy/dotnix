# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#nixpc -- <disk>
{ self, ... }: {
  perSystem = { pkgs, ... }: {
    apps.nixpc.program = pkgs.writeShellApplication {
      name = "nixpc";
      runtimeInputs = with pkgs; [
        age
        git
        disko
      ];
      text = ''
        if [ "$EUID" -eq 0 ]; then
          echo "Run nixpc without sudo"
          exit 1
        fi

        if [ "$#" -ne 1 ] || [ ! -b "$1" ]; then
          echo "Usage: nixpc <disk>" >&2
          echo "Find the disk name with: lsblk -pdo NAME,SIZE,MODEL" >&2
          exit 2
        fi

        umask 0077
        target=$(mktemp -d); mkdir "$target/.ssh"

        git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git https://github.com/radutomy/dotnix "$target/dotnix"

        age -d ${self}/secrets/ssh_keys.age > "$target/.ssh/id_ed25519"

        sudo disko-install \
          --flake "path:$target/dotnix#nixpc" \
          --disk main "$1" \
          --extra-files "$target" /persistent/home/radu
      '';
    };
  };
}

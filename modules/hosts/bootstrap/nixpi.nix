_: {
  perSystem = { pkgs, ... }: {
    apps.nixpi.program = pkgs.writeShellApplication {
      name = "nixpi";
      runtimeInputs = with pkgs; [
        git
        nixos-anywhere
      ];
      text = ''
        if [ "$#" -ne 1 ]; then
          echo "Usage: nixpi root@<installer-ip>" >&2
          exit 2
        fi

        files=$(mktemp -d)
        trap 'rm -rf "$files"' EXIT
        mkdir -p "$files/root"
        git clone -c remote.origin.pushurl=git@github.com:radutomy/dotnix.git \
          https://github.com/radutomy/dotnix "$files/root/dotnix"

        nixos-anywhere \
          --flake "path:$files/root/dotnix#nixpi" \
          --phases disko,install,reboot \
          --extra-files "$files" \
          --target-host "$1"
      '';
    };
  };
}

# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#ubuntu
{ self, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      bootstrap =
        name:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = with pkgs; [
            age
            git
          ];
          text = ''
            umask 0077

            if [ -d "$HOME/dotnix" ]; then
              git -C "$HOME/dotnix" pull --ff-only
            else
              git clone https://github.com/radutomy/dotnix "$HOME/dotnix"
            fi

            install -d -m 700 "$HOME/.ssh"

            if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
              age -d ${self}/secrets/ssh_keys.age > "$HOME/.ssh/id_ed25519"
            fi

            chmod 600 "$HOME/.ssh/id_ed25519"

            nix run --option experimental-features "nix-command flakes" \
              github:nix-community/home-manager -- switch -b bak --flake "$HOME/dotnix"

            git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
            "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
          '';
        };
    in
    {
      apps.ubuntu.program = bootstrap "ubuntu";
    };
}

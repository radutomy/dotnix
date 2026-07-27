# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#<wsl|orb|nas>
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

            nixos-rebuild switch \
              --option experimental-features "nix-command flakes" \
              --flake "$HOME/dotnix#${name}"

            hostnamectl set-hostname "${name}" || hostname "${name}"
            git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
            "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
          '';
        };
    in
    {
      apps = {
        wsl.program = bootstrap "wsl";
        orb.program = bootstrap "orb";
        nas.program = bootstrap "nas";
      };
    };
}

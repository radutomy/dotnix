# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#<wsl|orb>
_: {
  perSystem =
    { pkgs, ... }:
    let
      bootstrap =
        name:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ pkgs.git ];
          text = ''
            if [ -d "$HOME/dotnix" ]; then
              git -C "$HOME/dotnix" pull --ff-only
            else
              git clone https://github.com/radutomy/dotnix "$HOME/dotnix"
            fi

            nixos-rebuild switch \
              --option experimental-features "nix-command flakes" \
              --flake "$HOME/dotnix#${name}"

            hostnamectl set-hostname "${name}" || hostname "${name}"
            "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
          '';
        };
    in
    {
      apps = {
        wsl.program = bootstrap "wsl";
        orb.program = bootstrap "orb";
      };
    };
}

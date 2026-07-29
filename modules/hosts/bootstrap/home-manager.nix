# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#ubuntu
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

            nix run --option experimental-features "nix-command flakes" \
              github:nix-community/home-manager -- switch -b bak --flake "$HOME/dotnix"

            "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
          '';
        };
    in
    {
      apps.ubuntu.program = bootstrap "ubuntu";
    };
}

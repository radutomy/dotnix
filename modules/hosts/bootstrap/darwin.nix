# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#macos
{ inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;

  macos = pkgs.writeShellApplication {
    name = "macos";
    runtimeInputs = [ pkgs.git ];
    text = ''
      if [ -d "$HOME/dotnix" ]; then
        git -C "$HOME/dotnix" pull --ff-only
      else
        git clone https://github.com/radutomy/dotnix "$HOME/dotnix"
      fi

      sudo ${inputs.nix-darwin.packages.aarch64-darwin.darwin-rebuild}/bin/darwin-rebuild \
        switch --flake "$HOME/dotnix#darwin"
    '';
  };
in
{
  flake.apps.aarch64-darwin.macos = {
    type = "app";
    program = "${macos}/bin/macos";
  };
}

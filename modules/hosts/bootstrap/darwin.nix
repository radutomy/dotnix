# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#macos
{ self, inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;

  macos = pkgs.writeShellApplication {
    name = "macos";
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

      sudo ${inputs.nix-darwin.packages.aarch64-darwin.darwin-rebuild}/bin/darwin-rebuild \
        switch --flake "$HOME/dotnix#darwin"

      git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
    '';
  };
in
{
  flake.apps.aarch64-darwin.macos = {
    type = "app";
    program = "${macos}/bin/macos";
  };
}

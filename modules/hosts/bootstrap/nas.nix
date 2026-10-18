# nix --extra-experimental-features "nix-command flakes" run --refresh github:radutomy/dotnix#nas
{ self, ... }: {
  perSystem = { pkgs, ... }: {
    apps.nas.program = pkgs.writeShellApplication {
      name = "nas";
      runtimeInputs = with pkgs; [
        age
        git
      ];
      text = ''
        if [ -d "$HOME/dotnix" ]; then
          git -C "$HOME/dotnix" pull --ff-only
        else
          git clone https://github.com/radutomy/dotnix "$HOME/dotnix"
        fi

        if [ ! -s /var/lib/agenix/nas.agekey ]; then
          install -d -m 700 /var/lib/agenix
          age -d -o /var/lib/agenix/nas.agekey ${self}/secrets/nas.agekey.age
          chmod 600 /var/lib/agenix/nas.agekey
        fi

        nixos-rebuild switch \
          --option experimental-features "nix-command flakes" \
          --flake "$HOME/dotnix#nas"

        hostnamectl set-hostname nas || hostname nas
        "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
      '';
    };
  };
}

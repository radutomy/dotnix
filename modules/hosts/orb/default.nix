{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps.orb = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "orb";
            runtimeInputs = with pkgs; [
              age
              git
            ];
            text = ''
              git clone -b main https://github.com/radutomy/dotnix "$HOME/dotnix"
              install -d -m 700 "$HOME/.ssh"
              age -d -o "$HOME/.ssh/id_ed25519" "$HOME/dotnix/secrets/ssh_keys.age"
              chmod 600 "$HOME/.ssh/id_ed25519"
              nixos-rebuild switch \
                --option experimental-features "nix-command flakes" \
                --flake "$HOME/dotnix#orb"
              git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
              nvim --headless "+Lazy! sync" +qa
            '';
          }
        }/bin/orb";
      };
    };

  flake.nixosConfigurations.orb = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      self.nixosModules.base
      self.nixosModules.fish
      self.nixosModules.git
      self.nixosModules.nvim
      self.nixosModules.orb
      self.nixosModules.rust
      self.nixosModules.tmux
      self.nixosModules.work
    ];
  };
}

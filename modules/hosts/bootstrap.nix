{
  perSystem =
    { pkgs, self', ... }:
    {
      _module.args.mkBootstrapApp =
        name:
        pkgs.writeShellApplication {
          inherit name;

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
              --flake "$HOME/dotnix#${name}"

            git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
            nvim --headless "+Lazy! sync" +qa

            ${self'.packages.cloneWorkRepos}/bin/clone-work-repos || {
              echo "Cloning work repos failed... is the VPN on?" >&2
              echo "Re-try with: nix run github:radutomy/dotnix#cloneWorkRepos" >&2
            }
          '';
        };
    };
}

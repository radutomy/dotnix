# provisioning apps: nix run github:radutomy/dotnix#<machine> on a fresh box.
# each clones the repo + ssh key, provisions with `switch`, then finishes setup
_: {
  perSystem =
    { pkgs, ... }:
    let
      bootstrap =
        name: switch:
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

            ${switch}

            git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
            nvim --headless "+Lazy! sync" +qa
          '';
        };

      # the two ways of applying the config: rebuild the NixOS system,
      # or (on a foreign distro) switch just the home
      nixos = name: ''
        nixos-rebuild switch \
          --option experimental-features "nix-command flakes" \
          --flake "$HOME/dotnix#${name}"

        hostnamectl set-hostname "${name}" || hostname "${name}"
      '';

      home = ''
        nix run \
          --option experimental-features "nix-command flakes" \
          github:nix-community/home-manager -- switch -b bak --flake "$HOME/dotnix"
      '';
    in
    {
      apps = {
        wsl.program = bootstrap "wsl" (nixos "wsl");
        orb.program = bootstrap "orb" (nixos "orb");
        nas.program = bootstrap "nas" (nixos "nas");
        ubuntu.program = bootstrap "ubuntu" home;
      };
    };
}

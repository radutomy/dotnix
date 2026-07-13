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
            if [ -d "$HOME/dotnix" ]; then
              git -C "$HOME/dotnix" pull --ff-only
            else
              git clone -b main https://github.com/radutomy/dotnix "$HOME/dotnix"
            fi

            install -d -m 700 "$HOME/.ssh"

            if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
              age -d -o "$HOME/.ssh/id_ed25519" "$HOME/dotnix/secrets/ssh_keys.age"
            fi

            chmod 600 "$HOME/.ssh/id_ed25519"

            ${switch}

            git -C "$HOME/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git
            "$HOME/.nix-profile/bin/nvim" --headless "+Lazy! sync" +qa
          '';
        };

      # the two ways of applying the config: rebuild the NixOS system,
      # or (on a foreign distro) switch just the home
      nixos = name: elevate: ''
        ${elevate}nixos-rebuild switch \
          --option experimental-features "nix-command flakes" \
          --flake "$HOME/dotnix#${name}"

        ${elevate}hostnamectl set-hostname "${name}" || ${elevate}hostname "${name}"
      '';

      home = ''
        nix run \
          --option experimental-features "nix-command flakes" \
          github:nix-community/home-manager -- switch -b bak --flake "$HOME/dotnix"
      '';
    in
    {
      apps = {
        wsl.program = bootstrap "wsl" (nixos "wsl" "");
        orb.program = bootstrap "orb" (nixos "orb" "");
        nas.program = bootstrap "nas" (nixos "nas" "");
        nixpc.program = bootstrap "nixpc" (nixos "nixpc" "sudo ");
        ubuntu.program = bootstrap "ubuntu" home;
      };
    };
}

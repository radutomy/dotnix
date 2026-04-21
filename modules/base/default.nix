{ inputs, ... }:
{
  flake.nixosModules.base =
    { pkgs, dotnix, ... }:
    {
      _module.args.dotnix = "$HOME/dotnix"; # global variable to declare dotnix folder
      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };

      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.codex.overlays.default
        inputs.gemini-cli.overlays.default
      ];

      environment.shellAliases = {
        ls = "lsd --group-dirs=first";
        ll = "lsd -lah --group-dirs=first";
        l = "lsd -A --group-dirs=first";
        cat = "bat --style=plain";
        p = "python";
        gg = "lazygit";
        ns = "nh os switch ${dotnix} --bypass-root-check";
        nu = "nh os switch ${dotnix} --update --bypass-root-check && git -C ${dotnix} commit -m 'flake.lock' -- flake.lock && git -C ${dotnix} push";
      };

      programs.nh = {
        enable = true;
        flake = dotnix;
      };

      environment.systemPackages = with pkgs; [
        git
        jq
        bat
        age

        tmux
        wget

        claude-code
        codex
        gemini-cli
      ];

      programs.ssh.extraConfig = ''
        Host *
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
      '';
    };
}

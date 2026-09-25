# Shared NixOS configuration.
{ inputs, ... }: {
  flake.modules.nixos.base = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.channel.enable = false;
    programs.nh.clean = {
      enable = true;
      extraArgs = "--keep 10 --no-gcroots";
    };
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
  };
}

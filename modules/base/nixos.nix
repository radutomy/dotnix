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
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
  };
}

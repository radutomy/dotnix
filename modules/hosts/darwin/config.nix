{ inputs, ... }:
{
  flake.modules.darwin.darwin-config =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      nixpkgs.hostPlatform = "aarch64-darwin";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];

      users.users.radu = {
        home = "/Users/radu";
        shell = pkgs.fish;
      };

      system = {
        primaryUser = "radu";
        stateVersion = 6;
      };

      networking.hostName = "darwin";
      time.timeZone = "Europe/London";
    };
}

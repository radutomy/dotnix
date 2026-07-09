# nix-on-ubuntu machine (not NixOS): standalone home-manager only.
{ self, inputs, ... }:
{
  flake.homeConfigurations.radu = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      self.modules.homeManager.base
      self.modules.homeManager.ai
      self.modules.homeManager.fish
      self.modules.homeManager.git
      self.modules.homeManager.nvim
      self.modules.homeManager.rust
      self.modules.homeManager.csharp
      self.modules.homeManager.tmux
      (
        { pkgs, ... }:
        {
          home.username = "radu";
          home.homeDirectory = "/home/radu";

          # home-manager can't chsh on a foreign distro; hand bash off to fish
          programs.bash = {
            enable = true;
            initExtra = ''
              if [[ -z "''${BASH_EXECUTION_STRING:-}" && -z "''${IN_NIX_SHELL:-}" ]]; then
                exec ${pkgs.fish}/bin/fish
              fi
            '';
          };
        }
      )
    ];
  };
}

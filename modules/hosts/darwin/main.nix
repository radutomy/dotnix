{ self, inputs, ... }:
let
  homeModule =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.base
        self.modules.homeManager.ai
        self.modules.homeManager.fish
        self.modules.homeManager.git
        self.modules.homeManager.nvim
        self.modules.homeManager.rust
        self.modules.homeManager.tmux
      ];

      home.packages = with pkgs; [
        wezterm
        spotify
      ];
    };
in
{
  flake.darwinConfigurations.darwin = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.modules.darwin.darwin-config
      {
        home-manager.users.radu = homeModule;
      }
    ];
  };
}

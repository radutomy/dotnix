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
        self.modules.homeManager.coscli
        self.modules.homeManager.cosmic
        self.modules.homeManager.firefox
        self.modules.homeManager.glances
      ];

      home.packages = with pkgs; [
        # My taskbar applet for killing memory-heavy processes
        inputs.cosmic-process-applet.packages.${pkgs.stdenv.hostPlatform.system}.default

        vscodium
        wezterm
        simplenote
        discord
        chromium
        spotify
        bitwarden-desktop
      ];
    };
in
{
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixpc-config
      self.modules.nixos.nixpcDisko
      self.modules.nixos.nixpcPreservation
      self.modules.nixos.nixpcHardware
      self.modules.nixos.cosmic
      self.modules.nixos.steam
      self.modules.nixos.hwshared
      {
        home-manager.users.radu = homeModule;
      }
    ];
  };
}

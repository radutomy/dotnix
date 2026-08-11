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
        self.modules.homeManager.autostart
        self.modules.homeManager.cosmic
        self.modules.homeManager.firefox
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
  flake.nixosConfigurations.nixqs = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixqs-config
      self.modules.nixos.nixqsDisko
      self.modules.nixos.nixqsPreservation
      self.modules.nixos.nixqsHardware
      self.modules.nixos.cosmic
      self.modules.nixos.steam
      self.modules.nixos.work
      self.modules.nixos.hwshared
      {
        home-manager.users.radu = homeModule;
      }
    ];
  };
}

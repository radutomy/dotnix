# Shared by every NixOS host with a graphical desktop (nixqs, nixpc).
{ self, inputs, ... }: {
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.cosmic
      self.modules.nixos.steam
      self.modules.nixos.hwshared
    ];
  };

  flake.modules.homeManager.desktop = { pkgs, ... }: {
    imports = [
      self.modules.homeManager.base
      self.modules.homeManager.ai
      self.modules.homeManager.fish
      self.modules.homeManager.git
      self.modules.homeManager.nvim
      self.modules.homeManager.rust
      self.modules.homeManager.tmux
      self.modules.homeManager.cosmic
      self.modules.homeManager.firefox
    ];

    home.packages = with pkgs; [
      # My taskbar applet for killing memory-heavy processes
      inputs.cosmic-process-applet.packages.${pkgs.stdenv.hostPlatform.system}.default
      vscodium
      wezterm
      simplenote
      chromium
      spotify
      bitwarden-desktop
    ];
  };
}

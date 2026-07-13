_: {
  flake.modules.nixos.hyprland = _: {
    programs.hyprland.enable = true;
    hardware.graphics.enable = true;
  };

  flake.modules.homeManager.hyprland = {
    wayland.windowManager.hyprland = {
      enable = true;
      settings.config.input = {
        sensitivity = -0.75;
        accel_profile = "adaptive";
      };
    };
  };
}

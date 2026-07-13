_: {
  # System side: Hyprland with DankMaterialShell and its matching greeter.
  flake.modules.nixos.hyprland = _: {
    programs.hyprland.enable = true;
    programs.dms-shell.enable = true;
    hardware.graphics.enable = true;

    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "radu";
      };
      defaultSession = "hyprland";

      dms-greeter = {
        enable = true;
        compositor.name = "hyprland";
      };
    };
  };

  flake.modules.homeManager.hyprland = _: {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "wezterm";

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, D, exec, dms ipc call spotlight toggle"
          "$mod, Q, killactive"
        ];
      };
    };
  };
}

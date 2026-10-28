_: {
  flake.modules.homeManager.wezterm = {
    programs.wezterm = {
      enable = true;
      settings = {
        color_scheme = "Vs Code Dark+ (Gogh)";
        colors = {
          foreground = "#F2F2F2";
          cursor_bg = "#C44300";
        };
        disable_default_key_bindings = true;
        notification_handling = "NeverShow";
        window_decorations = "RESIZE";
        font_size = 11;
        warn_about_missing_glyphs = false;
        window_close_confirmation = "NeverPrompt";
        adjust_window_size_when_changing_font_size = false;
        mux_enable_ssh_agent = false;
        # swallow_mouse_click_on_window_focus = true;
        enable_tab_bar = false;
        keys = [
          {
            key = "v";
            mods = "CTRL";
            action.PasteFrom = "Clipboard";
          }
          {
            key = "=";
            mods = "CTRL";
            action = "IncreaseFontSize";
          }
          {
            key = "-";
            mods = "CTRL";
            action = "DecreaseFontSize";
          }
        ];
      };
    };
  };
}

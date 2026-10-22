_: {
  flake.modules.homeManager.yazi = { pkgs, ... }: {
    programs.yazi = {
      enable = true;
      plugins.toggle-pane = pkgs.yaziPlugins.toggle-pane;
      keymap.mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview";
        }
      ];
    };
  };
}

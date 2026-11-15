# Temporary fixes for lazyvim-nix; delete each block once fixed upstream, and this file and its import once empty
{ pkgs, ... }: {
  programs.lazyvim.plugins.nix-sources = with pkgs.vimPlugins; ''
    -- TODO: (tested broken 2026-11) remove this override once lazy.nvim identifies plugins in owner--plugin directories
    require("lazy.core.plugin").find = function(path, opts)
      local spec = require("lazy.core.config").spec
      if not spec then return end
      local plugins = opts and opts.fast and spec.meta.plugins or spec.plugins
      for _, plugin in pairs(plugins) do
        if path:sub(1, #plugin.dir + 5) == plugin.dir .. "/lua/" then
          return plugin
        end
      end
    end

    -- TODO: (2026-10) remove these entries once lazyvim-nix discovers user plugins from configFiles instead of ~/.config/nvim
    return {
      { name = "blink.cmp", dir = "${blink-cmp}" },
      { name = "markview.nvim", dir = "${markview-nvim}" },
      { name = "mini.cursorword", dir = "${mini-cursorword}" },
      { name = "toggleterm.nvim", dir = "${toggleterm-nvim}" },
      { name = "vscode.nvim", dir = "${vscode-nvim}" },
    }
  '';
}

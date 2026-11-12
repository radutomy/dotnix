# Temporary fixes for lazyvim-nix; delete each block once fixed upstream, and this file and its import once empty
{ pkgs, ... }: {
  # TODO: (2026-10) lazyvim-nix scans ~/.config/nvim instead of configFiles for user plugins, so they download unless listed here
  programs.lazyvim.plugins.nix-sources = with pkgs.vimPlugins; ''
    return {
      { name = "blink.cmp", dir = "${blink-cmp}" },
      { name = "markview.nvim", dir = "${markview-nvim}" },
      { name = "mini.cursorword", dir = "${mini-cursorword}" },
      { name = "toggleterm.nvim", dir = "${toggleterm-nvim}" },
      { name = "vscode.nvim", dir = "${vscode-nvim}" },
    }
  '';
}

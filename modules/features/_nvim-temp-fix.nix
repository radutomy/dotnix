# Temporary fixes for lazyvim-nix; delete each block once fixed upstream, and this file and its import once empty
{ pkgs, ... }: {
  # TODO: (check 2027-04) lazyvim-nix scans ~/.config/nvim instead of configFiles for user plugins, so they download unless listed here
  programs.lazyvim.plugins.nix-sources = with pkgs.vimPlugins; ''
    return {
      { name = "blink.cmp", dir = "${blink-cmp}" },
      { name = "markview.nvim", dir = "${markview-nvim}" },
      { name = "mini.cursorword", dir = "${mini-cursorword}" },
      { name = "toggleterm.nvim", dir = "${toggleterm-nvim}" },
      { name = "vscode.nvim", dir = "${vscode-nvim}" },
    }
  '';

  # TODO: (tested broken 2026-11) check if lazyvim-nix merged https://github.com/pfassina/lazyvim-nix/pull/108
  # Test: drop this block, switch, and open a .diff file in nvim
  # lazyvim-nix builds the diff parser from a stale manifest but ships newer nvim-treesitter queries, which fail with
  # `Invalid node type "change"`; use the query that matches the installed parser instead
  xdg.configFile."nvim/queries/diff/highlights.scm".source = "${
    pkgs.fetchFromGitHub {
      owner = "tree-sitter-grammars";
      repo = "tree-sitter-diff";
      rev = "2520c3f934b3179bb540d23e0ef45f75304b5fed";
      sha256 = "1kjjg9x4s6qzyjz7j9qap6yscll0q3lzpdm3gvpjnr98d0s0pdpj";
    }
  }/queries/highlights.scm";
}

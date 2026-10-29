{ inputs, ... }: {
  flake.modules.homeManager.nvim = { pkgs, ... }: {
    imports = [ inputs.lazyvim-nix.homeManagerModules.default ];

    programs.neovim = {
      defaultEditor = true;
      vimAlias = true;
    };

    programs.lazyvim = {
      enable = true;
      ignoreBuildNotifications = true;
      configFiles = ../../nvim;
      treesitterParsers = [ pkgs.vimPlugins.nvim-treesitter-parsers.fish ];

      # TODO: (check 2027-04) lazyvim-nix scans ~/.config/nvim instead of configFiles for user plugins, so they download unless listed here; if fixed upstream, delete this block
      plugins.nix-sources = with pkgs.vimPlugins; ''
        return {
          { name = "blink.cmp", dir = "${blink-cmp}" },
          { name = "markview.nvim", dir = "${markview-nvim}" },
          { name = "mini.cursorword", dir = "${mini-cursorword}" },
          { name = "toggleterm.nvim", dir = "${toggleterm-nvim}" },
          { name = "vscode.nvim", dir = "${vscode-nvim}" },
        }
      '';

      extras = {
        lang = {
          git.enable = true;
          json.enable = true;
          markdown.enable = true;
          nix.enable = true;
          rust.enable = true;
          toml.enable = true;
        };
        util = {
          dot.enable = true;
          mini-hipatterns.enable = true;
        };
      };
    };

    home.packages = with pkgs; [
      lua-language-server
      stylua
      shfmt
      bash-language-server
      vscode-json-languageserver
      marksman
      taplo
      deadnix
      nil
      nixfmt
      statix
    ];

    xdg.dataFile."nvim/lazy/lazy.nvim" = {
      source = pkgs.vimPlugins.lazy-nvim;
      recursive = true;
    };

    # Hide Home Manager's Neovim launcher.
    xdg.desktopEntries.nvim = {
      name = "Neovim";
      noDisplay = true;
    };
  };
}

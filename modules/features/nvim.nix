{ inputs, ... }: {
  flake.modules.homeManager.nvim = { pkgs, ... }: {
    imports = [
      inputs.lazyvim-nix.homeManagerModules.default
      ./_nvim-temp-fix.nix
    ];

    programs.neovim = {
      defaultEditor = true;
      vimAlias = true;
    };

    programs.lazyvim = {
      enable = true;
      ignoreBuildNotifications = true;
      configFiles = ../../nvim;
      treesitterParsers = [ pkgs.vimPlugins.nvim-treesitter-parsers.fish ];

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

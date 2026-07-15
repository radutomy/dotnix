_: {
  flake.modules.homeManager.nvim =
    { pkgs, config, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        sideloadInitLua = true;
      };

      home.packages = with pkgs; [
        # Lazyvim
        fd
        fzf
        gcc
        nodejs-slim
        ripgrep
        tree-sitter

        # Lua support
        lua-language-server
        stylua

        # Shell formatting
        shfmt

        # json
        vscode-json-languageserver

        # Markdown language server and linter
        markdownlint-cli2
        marksman

        # TOML formatting / linting
        taplo

        # Nix language server, formatter, linter, and dead code checker
        deadnix
        nil
        nixfmt
        statix
      ];

      # symlink the repo's neovim config into ~/.config
      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/nvim";

      # hide the wrapper's "Neovim wrapper" launcher entry
      xdg.desktopEntries.nvim = {
        name = "Neovim";
        noDisplay = true;
      };
    };
}

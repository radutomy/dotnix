_: {
  flake.nixosModules.nvim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
      };

      # symlink the repo's neovim config into ~/.config
      systemd.tmpfiles.rules = [ "L+ %h/.config/nvim - - - - %h/dotnix/nvim" ];

      environment.systemPackages = with pkgs; [
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
    };
}

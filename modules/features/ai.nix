{ inputs, ... }: {
  flake.modules.homeManager.ai = { config, ... }: {
    nixpkgs.overlays = [
      inputs.claude-code.overlays.default
      inputs.codex.overlays.default
    ];

    home = {
      sessionVariables.IS_SANDBOX = "1";
      # Makes Codex use $XDG_CONFIG_HOME/codex via CODEX_HOME
      preferXdgDirectories = true;
    };

    programs.claude-code = {
      enable = true;
      configDir = "${config.xdg.configHome}/claude";
      settings = {
        permissions.defaultMode = "bypassPermissions";
        enabledPlugins = {
          "lua-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
        };
        effortLevel = "medium";
        skipDangerousModePermissionPrompt = true;
        theme = "dark";
        tui = "fullscreen";
      };
    };

    programs.codex = {
      enable = true;
      settings = {
        approval_policy = "never";
        sandbox_mode = "danger-full-access";
        projects."${config.home.homeDirectory}/dotnix".trust_level = "trusted";
      };
    };
  };
}

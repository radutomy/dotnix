{ self, ... }: {
  flake.modules.homeManager.ai = { config, ... }: {
    xdg.configFile = {
      "codex/AGENTS.md".source = "${self}/agents/AGENTS.md";
      "codex/OPINIONS.md".source = "${self}/agents/OPINIONS.md";
      "claude/CLAUDE.md".source = "${self}/agents/AGENTS.md";
      "claude/OPINIONS.md".source = "${self}/agents/OPINIONS.md";
    };

    home = {
      sessionVariables = {
        IS_SANDBOX = "1";
        COPILOT_ALLOW_ALL = "true";
      };
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
        #tui = "fullscreen";
      };
    };

    programs.codex = {
      enable = true;
      settings = {
        approval_policy = "never";
        sandbox_mode = "danger-full-access";
        notice.hide_rate_limit_model_nudge = true;
        tui.status_line = [
          "model-with-reasoning"
          "current-dir"
          "git-branch"
          "weekly-limit"
        ];
        projects."${config.home.homeDirectory}/dotnix".trust_level = "trusted";
      };
    };

    # No settings: config.json also holds the login token now that
    # .config/copilot is persisted, so HM must not manage that file.
    # Set footer display (showModelEffort/showDirectory/showBranch/showQuota)
    # via Copilot's own /settings menu instead.
    programs.github-copilot-cli = {
      enable = true;
      context = "${self}/agents/AGENTS.md";
    };
  };
}

{ self, ... }: {
  flake.modules.homeManager.ai = { config, ... }: {
    xdg.configFile = {
      "codex/AGENTS.md".source = "${self}/agents/AGENTS.md";
      "claude/CLAUDE.md".source = "${self}/agents/AGENTS.md";
      "copilot/copilot-instructions.md".source = "${self}/agents/AGENTS.md";
    };

    home = {
      sessionVariables = {
        IS_SANDBOX = "1";
        COPILOT_ALLOW_ALL = "true";
      };
      preferXdgDirectories = true;
    };

    programs = {
      claude-code = {
        enable = true;
        configDir = "${config.xdg.configHome}/claude";
        settings = {
          attribution.commit = "";
          permissions.defaultMode = "bypassPermissions";
          enabledPlugins = {
            "lua-lsp@claude-plugins-official" = true;
            "rust-analyzer-lsp@claude-plugins-official" = true;
          };
          skipDangerousModePermissionPrompt = true;
          theme = "dark";
          tui = "default"; # fullscreen off
        };
      };

      codex = {
        enable = true;
        mutableSettings = true;
        settings = {
          approval_policy = "never";
          sandbox_mode = "danger-full-access";
          notice.hide_rate_limit_model_nudge = true;
          tui.alternate_screen = "never";
          tui.status_line = [
            "model-with-reasoning"
            "current-dir"
            "git-branch"
            "weekly-limit"
          ];
        };
      };

      github-copilot-cli = {
        enable = true;
        mutableSettings = true;
        settings = {
          includeCoAuthoredBy = false;
          theme = "default";
          banner = "never";
          showTipsOnStartup = false;
          footer = {
            showModelEffort = true;
            showQuota = true;
            showPullRequest = false;
            showAiUsed = false;
            showAgent = false;
            showSandbox = false;
            showSchedules = false;
            showCustom = false;
          };
        };
      };
    };

  };
}

{ inputs, ... }:
{
  flake.modules.homeManager.ai = _: {
    nixpkgs.overlays = [
      inputs.claude-code.overlays.default
      inputs.codex.overlays.default
    ];

    # Lets Claude Code run with bypassPermissions as root
    home.sessionVariables.IS_SANDBOX = "1";

    programs.claude-code = {
      enable = true;
      settings = {
        permissions.defaultMode = "bypassPermissions";
        enabledPlugins = {
          "lua-lsp@claude-plugins-official" = true;
          "rust-analyzer-lsp@claude-plugins-official" = true;
        };
        effortLevel = "medium";
        skipDangerousModePermissionPrompt = true;
        theme = "dark";
      };
    };

    programs.codex = {
      enable = true;
      settings = {
        approval_policy = "never";
        sandbox_mode = "danger-full-access";
      };
    };
  };
}

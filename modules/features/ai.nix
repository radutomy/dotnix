{ inputs, ... }:
{
  flake.nixosModules.ai =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.codex.overlays.default
        inputs.gemini-cli.overlays.default
      ];

      # Lets Claude Code run with bypassPermissions as root
      environment.variables.IS_SANDBOX = "1";

      environment.systemPackages = with pkgs; [
        claude-code
        codex
        gemini-cli
      ];

      system.activationScripts.claudeSettings = "install -D -m 644 /root/dotnix/ai/claude.json /root/.claude/settings.json";
    };
}

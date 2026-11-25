{ lib, ... }: {
  flake.modules.nixos.nixqs-config = {
    networking.hostName = "nixqs";
    home-manager.users.radu = { config, ... }: {
      tmux.layout = "laptop";

      # TODO: we can remove this override once qs accepts yolo mode for codex
      programs.codex.settings = {
        approval_policy = lib.mkForce "on-request";
        sandbox_mode = lib.mkForce "workspace-write";
        approvals_reviewer = "auto_review";
        sandbox_workspace_write = {
          network_access = true;
          writable_roots = [ config.home.homeDirectory ];
        };
      };
    };

    services = {
      tailscale.extraSetFlags = [ "--accept-routes" ];
      logind.settings.Login.HandleLidSwitch = "ignore";
    };
  };
}

_: {
  flake.modules.nixos.nixqs-config = {
    networking.hostName = "nixqs";
    home-manager.users.radu.tmux.layout = "laptop";
    services = {
      tailscale.extraSetFlags = [ "--accept-routes" ];
      logind.settings.Login.HandleLidSwitch = "ignore";
    };
  };
}

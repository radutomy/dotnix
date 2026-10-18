_: {
  flake.modules.nixos.nixmi-config = {
    networking.hostName = "nixmi";
    home-manager.users.radu.tmux.layout = "laptop";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    services.fprintd.enable = true;
    preservation.preserveAt."/persistent".directories = [ "/var/lib/fprint" ];
  };
}

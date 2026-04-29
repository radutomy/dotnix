_: {
  flake.nixosModules.tailscale = _: {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      extraSetFlags = [
        "--advertise-exit-node"
        "--advertise-routes=192.168.0.0/24"
      ];
    };
  };
}

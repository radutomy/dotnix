_: {
  flake.modules.nixos.nixmi-config = {
    networking.hostName = "nixmi";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
  };
}

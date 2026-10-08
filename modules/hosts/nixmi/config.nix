_: {
  flake.modules.nixos.nixmi-config = {
    networking.hostName = "nixmi";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];

    services.fprintd.enable = true;
    preservation.preserveAt."/persistent".directories = [ "/var/lib/fprint" ];
  };
}

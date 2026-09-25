# Shared desktop config lives in modules/base/desktop.nix
_: {
  flake.modules.nixos.nixqs-config = {
    networking = {
      hostName = "nixqs";
      firewall.trustedInterfaces = [ "enp131s0" ];
    };

    services.tailscale.extraSetFlags = [ "--accept-routes" ];
  };
}

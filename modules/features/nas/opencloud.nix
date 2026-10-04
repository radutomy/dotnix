_: {
  flake.modules.nixos.opencloud = {
    services.opencloud = {
      enable = true;
      address = "0.0.0.0";
      url = "https://nas:9200";
      stateDir = "/tank/opencloud";
    };

    networking.firewall.allowedTCPPorts = [ 9200 ];
    systemd.services.opencloud.unitConfig.RequiresMountsFor = "/tank";
  };
}

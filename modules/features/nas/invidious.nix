# http://192.168.0.2:3001
_: {
  flake.modules.nixos.invidious = {
    services.invidious = {
      enable = true;
      address = "0.0.0.0";
      port = 3001;
    };

    networking.firewall.allowedTCPPorts = [ 3001 ];
  };
}

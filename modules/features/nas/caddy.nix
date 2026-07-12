_: {
  flake.modules.nixos.caddy = {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "http://home.me".extraConfig = "reverse_proxy 127.0.0.1:8123";
        "http://immich.me".extraConfig = "reverse_proxy 127.0.0.1:2283";
        "http://adguard.me".extraConfig = "reverse_proxy 127.0.0.1:3000";
        "http://invidious.me".extraConfig = "reverse_proxy 127.0.0.1:3001";
        "http://nas.me".extraConfig = "reverse_proxy 127.0.0.1:61208";
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}

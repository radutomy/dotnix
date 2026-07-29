let
  proxy = port: ''
    tls internal
    reverse_proxy 127.0.0.1:${toString port}
  '';
in
_: {
  flake.modules.nixos.caddy = {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "home.me".extraConfig = proxy 8123;
        "drive.me".extraConfig = proxy 8080;
        "immich.me".extraConfig = proxy 2283;
        "adguard.me".extraConfig = proxy 3000;
        "invidious.me".extraConfig = proxy 3001;
        "nas.me".extraConfig = proxy 61208;
        "owncloud.me".extraConfig = proxy 9200;
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}

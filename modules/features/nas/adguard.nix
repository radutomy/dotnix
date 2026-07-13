# http://192.168.0.2:3000
_: {
  flake.modules.nixos.adguard = {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      mutableSettings = false;
      allowDHCP = true;
      settings = {
        users = [
          {
            name = "adguard.a1@rtom.dev";
            password = "$2b$12$UcAwxsOhnFO673G6EJo/r.Nxdx94Vw1wnxlM/U4BrI03jLNq15Xg2";
          }
        ];

        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = 53;
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.quad9.net/dns-query"
          ];
          bootstrap_dns = [
            "1.1.1.1"
            "9.9.9.9"
          ];
        };

        filters = [
          {
            enabled = true;
            url = "https://big.oisd.nl/";
            name = "OISD Big";
            id = 1;
          }
          {
            enabled = true;
            url = "https://zoso.ro/pages/rolist.txt";
            name = "ROList (Romanian)";
            id = 3;
          }
        ];

        filtering.rewrites =
          map
            (domain: {
              enabled = true;
              inherit domain;
              answer = "192.168.0.2";
            })
            [
              "nas.me"
              "home.me"
              "adguard.me"
              "immich.me"
              "invidious.me"
              "owncloud.me"
              "drive.me"
            ];

        # AdGuard is the LAN's DHCP server. The Sky hub's built-in DHCP
        # ("Use Router as DHCP Server" at 192.168.0.1) must stay disabled,
        # or the two would hand out conflicting leases.
        dhcp = {
          enabled = true;
          interface_name = "enp7s0";
          local_domain_name = "lan";
          dhcpv4 = {
            gateway_ip = "192.168.0.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.0.50";
            range_end = "192.168.0.250";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [
      53
      67
      68
    ];
  };
}

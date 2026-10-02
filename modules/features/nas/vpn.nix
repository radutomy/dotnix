_: {
  flake.modules.nixos.vpn = { config, lib, ... }: {
    config = {
      age.secrets.proton-wg.file = ../../../secrets/proton-wg.age;

      networking.wireguard.interfaces.proton0 = {
        interfaceNamespace = "proton";
        preSetup = "ip netns add proton";
        postSetup = "ip -n proton link set lo up";
        postShutdown = "ip netns del proton";
        privateKeyFile = config.age.secrets.proton-wg.path;
        ips = [
          "10.2.0.2/32"
          "2a07:b944::2:2/128"
        ];
        peers = [
          {
            # UK#286, P2P with port forwarding
            publicKey = "lMm8Gocz1SIU/eAhpBzPHIWvAxJ30Oyeaj2PvmNl/Qk=";
            endpoint = "146.70.204.178:51820";
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            persistentKeepalive = 25;
          }
        ];
      };

      environment.etc."netns/proton/resolv.conf".text = ''
        nameserver 10.2.0.1
        nameserver 2a07:b944::2:1
      '';
    };

    # Adds `vpn = true;` to every systemd service: it then runs inside the namespace,
    # starting and stopping with the tunnel
    options.systemd.services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }: {
            options.vpn = lib.mkEnableOption "running this service through the VPN";
            config = lib.mkIf config.vpn {
              bindsTo = [ "wireguard-proton0.service" ];
              partOf = [ "wireguard-proton0.service" ];
              after = [ "wireguard-proton0.service" ];
              serviceConfig = {
                NetworkNamespacePath = "/run/netns/proton";
                BindReadOnlyPaths = [ "/etc/netns/proton/resolv.conf:/etc/resolv.conf" ];
                InaccessiblePaths = [ "/run/nscd" ];
              };
            };
          }
        )
      );
    };
  };
}

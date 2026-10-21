# Reaching the radios: nixqs by cable, or the PCs below through a virtual Ethernet cable over Tailscale.
# The Pi bridges its Ethernet port (with the radio on it) into a VXLAN tunnel,
# and the PC gets the other end as radio-tailscale, as if the radio were plugged into it
let
  hosts = {
    nixpc = "3";
    nixqs = "4";
    nixmi = "5";
  };
  ipv4 = host: {
    method = "manual";
    address1 = "10.19.0.${host}/16"; # RadioNOR, radio at 10.19.14.158
    address2 = "172.18.0.${host}/16"; # Silvus, radio at 172.18.135.178
    never-default = true;
  };
  tunnel = remote: connection: {
    connection = {
      id = "radio-tailscale";
      type = "vxlan";
      interface-name = "radio-tailscale";
    }
    // connection;
    vxlan = {
      id = 19;
      destination-port = 4789;
    }
    // remote;
  };
in
{
  flake.modules.nixos.radio-cable = { config, ... }: {
    systemd.network.links."10-radio-cable" = {
      matchConfig.Driver = "r8152";
      linkConfig.Name = "radio-cable";
    };
    networking = {
      firewall.trustedInterfaces = [ "radio-cable" ];
      networkmanager.settings.main.no-auto-default = "radio-cable";
      networkmanager.ensureProfiles.profiles.radio-cable = {
        connection = {
          id = "radio-cable";
          type = "ethernet";
          interface-name = "radio-cable";
          autoconnect = true;
        };
        ipv4 = ipv4 hosts.${config.networking.hostName};
      };
    };
  };

  flake.modules.nixos.radio-tailscale-pi.networking = {
    firewall.interfaces.tailscale0.allowedUDPPorts = [ 4789 ];
    networkmanager.settings.main.no-auto-default = "end0";
    networkmanager.ensureProfiles.profiles = {
      radio-bridge = {
        connection = {
          id = "radio-bridge";
          type = "bridge";
          interface-name = "radio-bridge";
        };
        bridge.stp = false;
        ipv4.method = "disabled";
        ipv6.method = "disabled";
      };
      radio-port.connection = {
        id = "radio-port";
        type = "ethernet";
        interface-name = "end0";
        master = "radio-bridge";
        slave-type = "bridge";
      };
      radio-tailscale = tunnel { } {
        master = "radio-bridge";
        slave-type = "bridge";
      };
    };
    # A tunnel config takes only one remote, so all PCs are added once it is up
    networkmanager.dispatcherScripts = [
      {
        source = builtins.toFile "radio-tailscale" ''
          [ "$1" = radio-tailscale ] && [ "$2" = up ] || exit 0
          for n in ${toString (builtins.attrValues hosts)}; do
            bridge fdb append 00:00:00:00:00:00 dev radio-tailscale dst "100.68.0.$n"
          done
        '';
      }
    ];
  };

  flake.modules.nixos.radio-tailscale-pc = { config, ... }: {
    networking.firewall.trustedInterfaces = [ "radio-tailscale" ];
    networking.firewall.interfaces.tailscale0.allowedUDPPorts = [ 4789 ];
    networking.networkmanager.ensureProfiles.profiles.radio-tailscale =
      tunnel { remote = "100.68.0.50"; } { }
      // {
        # Its own fixed MAC, so the radios tell the PCs apart
        ethernet.cloned-mac-address = "02:19:00:00:00:0${hosts.${config.networking.hostName}}";
        ipv4 = ipv4 hosts.${config.networking.hostName};
        ipv6.method = "disabled";
      };
  };
}

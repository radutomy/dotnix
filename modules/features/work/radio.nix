# Reaching the radios: nixqs by cable, nixpc through a virtual Ethernet cable over Tailscale.
# The Pi bridges its Ethernet port (with the radio on it) into a VXLAN tunnel,
# and nixpc gets the other end as radio0, as if the radio were plugged into it
let
  ipv4 = {
    method = "manual";
    address1 = "10.19.127.10/16"; # RadioNOR
    address2 = "172.18.110.10/16"; # Silvus
    never-default = true;
  };
  tunnel = remote: connection: {
    connection = {
      id = "Radio tunnel";
      type = "vxlan";
      interface-name = "radio0";
    }
    // connection;
    vxlan = {
      id = 19;
      inherit remote;
      destination-port = 4789;
    };
  };
in
{
  flake.modules.nixos.radiocable = {
    systemd.network.links."10-radio-monitor" = {
      matchConfig.Driver = "r8152";
      linkConfig.Name = "radio-monitor";
    };
    networking = {
      firewall.trustedInterfaces = [ "radio-monitor" ];
      networkmanager.settings.main.no-auto-default = "radio-monitor";
      networkmanager.ensureProfiles.profiles.radios-monitor = {
        connection = {
          id = "Radios (monitor)";
          type = "ethernet";
          interface-name = "radio-monitor";
          autoconnect = true;
        };
        inherit ipv4;
      };
    };
  };

  flake.modules.nixos.radiotunnel-pi.networking = {
    firewall.interfaces.tailscale0.allowedUDPPorts = [ 4789 ];
    networkmanager.settings.main.no-auto-default = "end0";
    networkmanager.ensureProfiles.profiles = {
      radio-bridge = {
        connection = {
          id = "Radio bridge";
          type = "bridge";
          interface-name = "br-radio";
        };
        bridge.stp = false;
        ipv4.method = "disabled";
        ipv6.method = "disabled";
      };
      radio-port.connection = {
        id = "Radio port";
        type = "ethernet";
        interface-name = "end0";
        master = "br-radio";
        slave-type = "bridge";
      };
      radio-tunnel = tunnel "100.68.0.3" {
        master = "br-radio";
        slave-type = "bridge";
      };
    };
  };

  flake.modules.nixos.radiotunnel-pc.networking = {
    firewall.trustedInterfaces = [ "radio0" ];
    firewall.interfaces.tailscale0.allowedUDPPorts = [ 4789 ];
    networkmanager.ensureProfiles.profiles.radio-tunnel = tunnel "100.68.0.50" { } // {
      # Fixed MAC, so it only has to be added to the radio's MAC routing table once
      ethernet.cloned-mac-address = "02:19:00:00:00:10";
      inherit ipv4;
      ipv6.method = "disabled";
    };
  };
}

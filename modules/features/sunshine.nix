_: {
  # Remote desktop over Tailscale: connect with Moonlight
  flake.modules.nixos.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      settings.capture = "kms";
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };

    preservation.preserveAt."/persistent".users.radu.directories = [ ".config/sunshine" ];
  };
}

_: {
  flake.modules.nixos.nfs = {
    services.nfs.server = {
      enable = true;
      exports = {
        "/tank"."192.168.0.0/24" = [
          "rw"
          "no_root_squash"
        ];
        "/gdrive"."192.168.0.0/24" = [
          "rw"
          "no_root_squash"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 2049 ];
    networking.firewall.allowedUDPPorts = [ 2049 ];
  };
}

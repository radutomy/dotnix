_: {
  flake.modules.nixos.tang =
    { config, lib, ... }:
    {
      age.secrets = {
        tang-sig.file = ../../../secrets/tang-sig.age;
        tang-exc.file = ../../../secrets/tang-exc.age;
      };

      services.tang = {
        enable = true;
        ipAddressAllow = [ "192.168.0.0/24" ];
      };

      systemd.services."tangd@".serviceConfig = {
        LoadCredential = [
          "sig.jwk:${config.age.secrets.tang-sig.path}"
          "exc.jwk:${config.age.secrets.tang-exc.path}"
        ];
        ExecStart = lib.mkForce "${config.services.tang.package}/libexec/tangd %d";
      };

      networking.firewall.interfaces.enp7s0.allowedTCPPorts = [ 7654 ];
    };
}

_: {
  flake.modules.nixos.samba =
    { config, ... }:
    {
      age.secrets.samba-passdb = {
        file = ../../../secrets/samba.age;
        mode = "0600";
      };
      services = {

        samba = {
          enable = true;
          openFirewall = true;
          settings = {
            global."invalid users" = [ ];
            tank = {
              path = "/tank";
              "read only" = "no";
              "valid users" = "root";
              "force user" = "root";
            };
            drive = {
              path = "/drive";
              "read only" = "no";
              "valid users" = "root";
              "force user" = "root";
            };
          };
        };

        samba.settings.global."passdb backend" = "smbpasswd:${config.age.secrets.samba-passdb.path}";

        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
      };
    };
}

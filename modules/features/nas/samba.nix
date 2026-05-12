_: {
  flake.nixosModules.samba =
    { pkgs, lib, ... }:
    {
      environment.etc."samba/root.smbpasswd" = {
        text = "root:0:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:FDE38D6AAC7D08878AD6025CBA7FB8AF:[U          ]:LCT-6A037714:\n";
        mode = "0400";
      };

      services.samba = {
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
        };
      };

      services.samba-wsdd = {
        enable = true;
        openFirewall = true;
      };

      system.activationScripts.sambaUsers = {
        deps = [ "etc" ];
        text = ''
          PATH=$PATH:${lib.makeBinPath [ pkgs.samba ]}
          install -d -m 0755 /var/lib/samba/private
          pdbedit -i smbpasswd:/etc/samba/root.smbpasswd -e tdbsam:/var/lib/samba/private/passdb.tdb
        '';
      };
    };
}

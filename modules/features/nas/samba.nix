{
  flake.modules.nixos.samba =
    { pkgs, ... }:
    {
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
          vault = {
            path = "/tank/vault";
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

      # decrypt the root smbpasswd (age-encrypted to root's SSH key, which the
      # bootstrap lays down before this runs) and import it, so the plaintext
      # hash never lands in git or the world-readable nix store
      system.activationScripts.sambaUsers = {
        deps = [ "etc" ];
        text = ''
          install -d /var/lib/samba/private
          passdb=$(mktemp -p /run)
          trap 'rm -f "$passdb"' EXIT
          ${pkgs.age}/bin/age -d -i /root/.ssh/id_ed25519 ${../../../secrets/samba_passdb.age} > "$passdb"
          ${pkgs.samba}/bin/pdbedit -i smbpasswd:"$passdb" -e tdbsam:/var/lib/samba/private/passdb.tdb
        '';
      };
    };
}

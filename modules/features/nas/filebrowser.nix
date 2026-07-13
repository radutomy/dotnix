# http://drive.me  (read-only web view of the /drive gdrive mirror)
_: {
  flake.modules.nixos.filebrowser =
    { lib, ... }:
    {
      services.filebrowser = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 8080;
          root = "/drive";
          # First-run admin (quick setup); password is a bcrypt hash.
          username = "admin";
          password = "$2a$10$a.KgHFF9uPp.ePoOkXIM9uV4FjuHO/03XZKo8wL28wx5bdxD/W/G6";
        };
      };

      systemd.tmpfiles.settings.filebrowser."/drive".d = lib.mkForce {
        user = "root";
        mode = "0755";
      };
    };
}

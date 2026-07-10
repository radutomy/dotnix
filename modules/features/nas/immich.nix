# http://192.168.0.2:2283
_: {
  flake.modules.nixos.immich =
    { config, pkgs, ... }:
    {
      # Full JSON body for the admin-sign-up call below:
      # {"email":..., "password":..., "name":...}
      age.secrets.immich.file = ../../../secrets/immich.age;

      services.immich = {
        enable = true;
        openFirewall = true;
        host = "0.0.0.0";
        mediaLocation = "/tank/photos";
      };
      systemd = {

        tmpfiles.settings.immich-photos."/tank/photos".d = {
          user = "immich";
          group = "immich";
          mode = "0700";
        };

        services.immich-server.unitConfig.RequiresMountsFor = "/tank";

        services.immich-admin-signup = {
          after = [ "immich-server.service" ];
          requires = [ "immich-server.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            User = "immich";
            LoadCredential = "signup.json:${config.age.secrets.immich.path}";
            ExecStart = "${pkgs.curl}/bin/curl --retry 30 --retry-connrefused --json @%d/signup.json http://localhost:2283/api/auth/admin-sign-up";
          };
        };
      };
    };
}

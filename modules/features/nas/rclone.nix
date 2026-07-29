_: {
  flake.modules.nixos.rclone =
    { config, pkgs, ... }:
    {
      age.secrets."rclone.conf".file = ../../../secrets/rclone.age;

      programs.fuse.userAllowOther = true;
      systemd = {

        tmpfiles.settings.gdrive = {
          "/gdrive".d = {
            user = "root";
            group = "root";
            mode = "0755";
          };
          "/var/cache/rclone-gdrive".d = {
            user = "root";
            group = "root";
            mode = "0700";
          };
        };

        services.gdrive = {
          description = "Live Google Drive mount at /gdrive";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          environment.RCLONE_CONFIG = config.age.secrets."rclone.conf".path;

          serviceConfig = {
            ExecStart = ''
              ${pkgs.rclone}/bin/rclone mount gdrive: /gdrive \
                --allow-other \
                --cache-dir /var/cache/rclone-gdrive \
                --poll-interval 15s \
                --vfs-cache-mode writes \
                --vfs-cache-max-size 20G
            '';
            Restart = "on-failure";
            RestartSec = "10s";
          };
        };

        services.gdrive-mirror = {
          description = "Mirror Google Drive to /drive";
          startAt = "03:00";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          environment = {
            RCLONE_CONFIG = config.age.secrets."rclone.conf".path;
            RCLONE_CREATE_EMPTY_SRC_DIRS = "true";
            RCLONE_DRIVE_ACKNOWLEDGE_ABUSE = "true";
          };

          unitConfig.RequiresMountsFor = "/drive";

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.rclone}/bin/rclone sync gdrive: /drive";

            CapabilityBoundingSet = "";
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectHome = true;
          };
        };

        timers.gdrive-mirror.timerConfig.Persistent = true;
      };
    };
}

_: {
  flake.modules.nixos.rclone =
    { config, pkgs, ... }:
    {
      age.secrets."rclone.conf".file = ../../../secrets/rclone.age;

      systemd.services.gdrive-sync = {
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

      systemd.timers.gdrive-sync.timerConfig.Persistent = true;
    };
}

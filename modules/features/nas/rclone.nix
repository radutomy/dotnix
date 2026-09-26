_: {
  flake.modules.nixos.rclone = { config, pkgs, ... }: {
    age.secrets."rclone.conf".file = ../../../secrets/rclone.age;

    systemd = {
      tmpfiles.settings.gdrive."/gdrive".d = { };

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
          # The NFS export cache pins the mount, so drop it or rclone can't unmount
          ExecStop = "-${pkgs.nfs-utils}/bin/exportfs -f";
          CacheDirectory = "rclone-gdrive";
          CacheDirectoryMode = "0700";
          SuccessExitStatus = 143;
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };

      services.gdrive-mirror = {
        description = "Mirror Google Drive to /drive";
        startAt = "03:00";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        environment.RCLONE_CONFIG = config.age.secrets."rclone.conf".path;
        unitConfig.RequiresMountsFor = "/drive";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.rclone}/bin/rclone sync gdrive: /drive --create-empty-src-dirs --drive-acknowledge-abuse";

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

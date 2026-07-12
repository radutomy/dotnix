_: {
  flake.modules.nixos.owncloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      age.secrets.owncloud.file = ../../../secrets/owncloud.age;

      networking.hosts."127.0.0.1" = [ "owncloud.me" ];

      services.ocis = {
        enable = true;
        address = "127.0.0.1";
        port = 9200;
        url = "https://owncloud.me";
        configDir = "/var/lib/ocis/config";
        environment = {
          OCIS_INSECURE = "true";
          PROXY_TLS = "false";
        };
      };

      systemd.services.ocis-init = {
        before = [ "ocis.service" ];
        requiredBy = [ "ocis.service" ];
        unitConfig.ConditionPathExists = "!${config.services.ocis.configDir}/ocis.yaml";
        serviceConfig = {
          Type = "oneshot";
          User = "ocis";
          EnvironmentFile = config.age.secrets.owncloud.path;
          Environment = [ "OCIS_URL=${config.services.ocis.url}" ];
          ExecStart = "${lib.getExe pkgs.ocis_5-bin} init --config-path ${config.services.ocis.configDir} --insecure true";
        };
      };
    };
}

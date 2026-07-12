# http://192.168.0.2:8123
_: {
  flake.modules.nixos.home-assistant =
    { config, pkgs, ... }:
    {
      age.secrets.home-assistant.file = ../../../secrets/home-assistant.age;

      services.home-assistant = {
        enable = true;
        openFirewall = true;
        extraComponents = [
          "default_config"
          "tplink"
        ];
        config = {
          default_config = { };
          homeassistant = {
            name = "Home";
            latitude = 52.1895291;
            longitude = 0.1326012;
            elevation = 0;
            unit_system = "metric";
            time_zone = "Europe/London";
            currency = "GBP";
            country = "GB";
          };
          http.use_x_forwarded_for = true;
          http.trusted_proxies = [ "127.0.0.1" ];
        };
      };

      systemd.services.home-assistant-onboard = {
        after = [ "home-assistant.service" ];
        requires = [ "home-assistant.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          LoadCredential = "user.json:${config.age.secrets.home-assistant.path}";
          ExecStart = "${pkgs.curl}/bin/curl --retry 30 --retry-connrefused --json @%d/user.json http://localhost:8123/api/onboarding/users";
        };
      };
    };
}

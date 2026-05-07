# http://192.168.0.2:8082
_: {
  flake.nixosModules.homepage = _: {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      allowedHosts = "*";

      widgets = [
        {
          glances = {
            url = "http://localhost:61208";
            version = 4;
            cpu = true;
            mem = true;
            cputemp = true;
            disk = "/";
            diskUnits = "bytes";
          };
        }
      ];

      services = [
        {
          "NAS" = [
            {
              "Cockpit" = {
                href = "https://192.168.0.2:9090";
                description = "Server management";
                icon = "cockpit.png";
              };
            }
            {
              "Glances" = {
                href = "http://192.168.0.2:61208";
                description = "System monitoring";
                icon = "glances.png";
              };
            }
          ];
        }
      ];
    };
  };
}

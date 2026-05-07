# https://192.168.0.2:9090
_: {
  flake.nixosModules.cockpit =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cockpit ];

      services.cockpit = {
        enable = true;
        openFirewall = true;
        plugins = [ pkgs.cockpit-zfs ];
        allowed-origins = [ "*" ];
      };
    };
}

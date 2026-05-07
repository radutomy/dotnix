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

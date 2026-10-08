_: {
  flake.modules.nixos.nixmi-config =
    { config, pkgs, ... }:
    let
      lidClosed = pkgs.writeShellScript "lid-closed" ''
        ${pkgs.gnugrep}/bin/grep -q closed /proc/acpi/button/lid/LID0/state
      '';
    in
    {
      networking.hostName = "nixmi";
      services.tailscale.extraSetFlags = [ "--accept-routes" ];

      services.fprintd.enable = true;
      preservation.preserveAt."/persistent".directories = [ "/var/lib/fprint" ];

      # Docked with the lid closed the sensor is unreachable: skip straight to the password
      security.pam.services.cosmic-greeter.rules.auth.lid-closed = {
        control = "[success=1 default=ignore]";
        modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
        args = [
          "quiet"
          "${lidClosed}"
        ];
        order = config.security.pam.services.cosmic-greeter.rules.auth.fprintd.order - 10;
      };
    };
}

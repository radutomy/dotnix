_: {
  flake.modules.nixos.coolercontrol = { pkgs, ... }: {
    programs.coolercontrol.enable = true;
    environment.systemPackages = with pkgs; [
      lm_sensors
      liquidctl
    ];
  };
}

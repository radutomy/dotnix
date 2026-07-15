_: {
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        extest.enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      gamemode = {
        enable = true;
        settings.general.renice = 10;
      };
      gamescope.enable = true;
    };

    environment.systemPackages = [ pkgs.mangohud ];
  };
}

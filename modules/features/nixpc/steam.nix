_: {
  flake.modules.nixos.steam.programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamemode.enable = true;
  };
}

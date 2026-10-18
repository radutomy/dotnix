_: {
  flake.modules.nixos.steam = {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      gamemode.enable = true;
      gamescope.enable = true;
    };

    preservation.preserveAt."/persistent".users.radu.directories = [ ".local/share/Steam" ];
  };
}

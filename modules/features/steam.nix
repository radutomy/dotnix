{ inputs, ... }: {
  flake.modules.nixos.steam = { config, ... }: {
    imports = [ inputs.nixos-steam.nixosModules.default ];

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        client = {
          enable = true;
          # Wizard of Legend
          games."445980".compatTool = "proton_experimental";
          shortcuts = {
            GTA2 = {
              exe = "${config.users.users.radu.home}/.local/share/games/gta2/reG2-x86_64.AppImage";
            };
            QSim = {
              exe = "${config.users.users.radu.home}/assets/qsim/QSim_Vis.exe";
              compatTool = "proton_experimental";
              launchOptions = ''DXVK_CONFIG="dxgi.maxFrameRate=60" %command% --drone=vector_r24:48.124186:11.284649:549.215:300 --UI=true --GcsIp=127.0.0.1'';
            };
          };
        };
      };

      gamemode.enable = true;
      gamescope.enable = true;
    };

    preservation.preserveAt."/persistent".users.radu.directories = [ ".local/share/Steam" ];
  };
}

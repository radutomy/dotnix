_: {
  flake.modules.nixos.syncthing = { config, ... }: {
    services.syncthing = {
      enable = true;
      user = "radu";
      group = "users";
      dataDir = config.users.users.radu.home;
      openDefaultPorts = true;
      settings = {
        devices = {
          nixpc.id = "FCUW33E-TXYOH6X-6AKPCZN-QH46TFN-22GBFFK-4T2NXGN-LLFI5C7-5H6PNQS";
          nixqs.id = "WU5WC2Y-AT4UH55-B2H4V2R-QXOWN2R-Q2MQPQY-VUCVIVJ-GX7PYJD-N6P2HAD";
          nixmi.id = "7MEONYA-QLQVSTR-REHUYI6-D5P5YQS-DORHQWK-RE2YVSK-JGB745C-5MXV2AS";
        };
        folders.assets = {
          path = "${config.users.users.radu.home}/assets";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
          ignorePatterns = [
            "debug"
            "target"
            "__pycache__"
          ];
        };
        folders.games = {
          path = "${config.users.users.radu.home}/.local/share/games";
          devices = builtins.attrNames config.services.syncthing.settings.devices;
          ignorePatterns = [ "gta2_registry.ini" ];
        };
      };
    };

    preservation.preserveAt."/persistent".users.radu.directories = [
      ".config/syncthing"
      "assets"
      ".local/share/games"
    ];
  };
}

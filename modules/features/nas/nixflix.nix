{ inputs, ... }: {
  flake.modules.nixos.nixflix = { config, ... }: {
    imports = [ inputs.nixflix.nixosModules.default ];

    age.secrets.proton-vpn.file = ../../../secrets/proton-vpn.age;

    nixflix = {
      enable = true;
      vpn = {
        enable = true;
        accessibleFrom = [ "192.168.0.0/24" ];
        wgConfFile = config.age.secrets.proton-vpn.path;
      };

      torrentClients.qbittorrent = {
        enable = true;
        webuiPort = 9090;
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = {
            DefaultSavePath = "/tank/torrents";
            DisableAutoTMMByDefault = true;
          };
          Preferences.WebUI = {
            Username = "qbittorrent.q1@rtom.dev";
            Password_PBKDF2 = "@ByteArray(iG18cNqVSeP9RZs+RTKI2Q==:cvKI+kcp9B+d7m5TCzucpcpZ2Ououhgg9KN7Wk+6oYjEtr+PDlLOp4Ob9Ami/Wm7RwnwEvOg38+MTiID/4FVaA==)";
          };
        };
      };
    };
  };
}

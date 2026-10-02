# http://192.168.0.2:9090
_: {
  flake.modules.nixos.qbittorrent = { pkgs, ... }: {
    services.qbittorrent = {
      enable = true;
      webuiPort = 9090;
      openFirewall = true;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session.DefaultSavePath = "/tank/torrents";
        Preferences.WebUI = {
          Username = "qbittorrent.q1@rtom.dev";
          Password_PBKDF2 = "@ByteArray(iG18cNqVSeP9RZs+RTKI2Q==:cvKI+kcp9B+d7m5TCzucpcpZ2Ououhgg9KN7Wk+6oYjEtr+PDlLOp4Ob9Ami/Wm7RwnwEvOg38+MTiID/4FVaA==)";
        };
      };
    };

    systemd = {
      tmpfiles.settings.qbittorrent."/tank/torrents".d = {
        user = "qbittorrent";
        group = "qbittorrent";
      };
      services.qbittorrent.path = [ pkgs.python3 ]; # for search plugins
    };
  };
}

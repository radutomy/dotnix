{ self, ... }: {
  flake.modules.nixos.work = { pkgs, ... }: {
    imports = [
      self.modules.nixos.gstreamer
      self.modules.nixos.work-config
    ];
    home-manager.users.radu.imports = [ self.modules.homeManager.work ];
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5173 ];

    environment.systemPackages = with pkgs; [
      devenv
      git
      lazysql
      gcc
      mold
      ethtool
      usbutils
      arp-scan
      protobuf
      ffmpeg
      buf # protobuf language server, used by nvim
      pkg-config
      nodejs
      pnpm
      nssTools
      teams-for-linux
      tesseract
    ];
  };
}

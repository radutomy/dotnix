{ self, ... }: {
  flake.modules.nixos.dev = { pkgs, ... }: {
    imports = [
      self.modules.nixos.gstreamer
      self.modules.nixos.dev-config
    ];
    home-manager.users.radu.imports = [ self.modules.homeManager.dev ];
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

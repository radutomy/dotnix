{ self, ... }: {
  flake.modules.nixos.work = { pkgs, ... }: {
    imports = [
      self.modules.nixos.gstreamer
      self.modules.nixos.work-config
    ];

    environment.systemPackages = with pkgs; [
      devenv
      git
      git-lfs
      lazysql
      mold
      ethtool
      usbutils
      arp-scan
      tcpdump
      protobuf
      pkg-config
      nodejs
      pnpm
      nssTools
      teams-for-linux
    ];
  };
}

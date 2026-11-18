_: {
  flake.modules.nixos.dev-config = { lib, pkgs, ... }: {
    preservation.preserveAt."/persistent".users.radu.directories = [
      ".config/teams-for-linux"
      ".local/share/direnv"
      ".local/share/mise"
      ".local/state/mise"
    ];

    programs = {
      direnv = {
        enable = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
      };

      # nix-ld: lets prebuilt binaries find a dynamic linker
      nix-ld.enable = true;

      # Lets tcpdump capture packets without sudo (needs user in `pcap` group).
      tcpdump.enable = true;
    };

    # Some tools hardcode /bin/bash, which doesn't exist on NixOS
    systemd.tmpfiles.rules = [ "L+ /bin/bash - - - - ${lib.getExe pkgs.bash}" ];

    # Needed by programs.tcpdump above
    users.users.radu.extraGroups = [ "pcap" ];
  };

  flake.modules.homeManager.dev = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      devenv
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

    programs.mise = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile."teams-for-linux/config.json".text = builtins.toJSON {
      frame = false;
    };

    xdg.configFile."just/justfile".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/scripts/justfile";

    home.shellAliases.j = "just -g";

    programs.git.ignores = [ "mise.local.toml" ];
  };
}

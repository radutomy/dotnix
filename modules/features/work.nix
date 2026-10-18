let
  gst =
    pkgs: with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
      gst-rtsp-server
      gst-editing-services
    ];
in
{
  flake.modules.nixos.work = { pkgs, ... }: {
    environment = {
      systemPackages =
        with pkgs;
        [
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
        ]
        ++ gst pkgs;

      sessionVariables.PKG_CONFIG_PATH = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" (
        [
          pkgs.openssl
          pkgs.glib
        ]
        ++ gst pkgs
      );
      sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
        pkgs.lib.makeSearchPathOutput "out" "lib/gstreamer-1.0"
          (gst pkgs);
    };

    home-manager.users.radu = { config, pkgs, ... }: {
      programs.mise = {
        enable = true;
        enableFishIntegration = true;
      };

      xdg.configFile."teams-for-linux/config.json".text = builtins.toJSON {
        frame = false;
      };

      xdg.configFile."just/justfile".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wo/justfile";

      home = {
        packages = [ pkgs.teams-for-linux ];
        shellAliases.j = "just -g";
        file."src/mosaic-uxs_mosaic-core-rs/mise.local.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wo/mise-local.toml";
      };

      programs.git.ignores = [ "mise.local.toml" ];
    };

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
    systemd.tmpfiles.rules = [ "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" ];

    # Needed by programs.tcpdump above
    users.users.radu.extraGroups = [ "pcap" ];
  };
}

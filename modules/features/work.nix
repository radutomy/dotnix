# nix run .#cloneRepos
let
  clone = name: ''
    [ -d "$HOME/${name}/.git" ] || git clone git@github.com:radutomy/${name}.git "$HOME/${name}"
  '';
in
{
  flake.modules.nixos.work = { pkgs, ... }: {
    environment = {
      systemPackages = with pkgs; [
        devenv
        direnv
        git
        git-lfs
        just
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

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-rtsp-server
        gst_all_1.gst-editing-services
      ];

      sessionVariables.PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
        pkgs.openssl.dev
        pkgs.glib.dev
        pkgs.gst_all_1.gstreamer.dev
        pkgs.gst_all_1.gst-plugins-base.dev
        pkgs.gst_all_1.gst-plugins-good.dev
        pkgs.gst_all_1.gst-plugins-bad.dev
        pkgs.gst_all_1.gst-plugins-ugly.dev
        pkgs.gst_all_1.gst-rtsp-server.dev
        pkgs.gst_all_1.gst-editing-services.dev
      ];

      sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" [
        pkgs.gst_all_1.gstreamer.out
        pkgs.gst_all_1.gst-plugins-base.out
        pkgs.gst_all_1.gst-plugins-good.out
        pkgs.gst_all_1.gst-plugins-bad.out
        pkgs.gst_all_1.gst-plugins-ugly.out
        pkgs.gst_all_1.gst-libav.out
        pkgs.gst_all_1.gst-rtsp-server.out
        pkgs.gst_all_1.gst-editing-services.out
      ];
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

  perSystem = { pkgs, lib, ... }: {
    packages.cloneRepos = pkgs.writeShellApplication {
      name = "clone-repos";
      runtimeInputs = with pkgs; [
        git
        git-lfs
        openssh
      ];
      text = lib.concatMapStringsSep "\n" clone [
        "dotnix"
        "rustlings"
      ];
    };
  };

  flake.modules.nixos.work-radios.networking = {
    firewall.trustedInterfaces = [ "enp131s0" ];
    networkmanager.settings.main.no-auto-default = "enp131s0";
    networkmanager.ensureProfiles.profiles.radios = {
      connection = {
        id = "Radios";
        type = "ethernet";
        interface-name = "enp131s0";
        autoconnect = true;
      };

      ipv4 = {
        method = "manual";
        address1 = "10.19.127.10/16";
        address2 = "172.18.110.10/16";
        never-default = true;
      };
    };
  };
}

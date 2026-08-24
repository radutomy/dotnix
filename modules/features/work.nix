# nix run .#cloneRepos
let
  email = "radu@rtom.dev";
  name = "Radu T";
  repo = "git@github.com";
  repos = [
    {
      name = "dotnix";
      url = "radutomy/dotnix";
      branch = "main";
    }
    {
      name = "rustlings";
      url = "radutomy/rustlings";
      branch = "main";
    }
  ];
  clone = r: ''
    if [ ! -d "$HOME/${r.name}/.git" ]; then
      git clone -b ${r.branch} ${repo}:${r.url}.git "$HOME/${r.name}"
      git -C "$HOME/${r.name}" config --local user.email "${email}"
      git -C "$HOME/${r.name}" config --local user.name "${name}"
    fi
  '';
in
{
  flake.modules.nixos.work = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      devenv
      direnv
      git
      git-lfs
      just
      mise
      lazysql
      mold
      ethtool
      usbutils
      arp-scan
      tcpdump
      protobuf
      pkg-config
      nodejs-slim
      pnpm

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-rtsp-server
      gst_all_1.gst-editing-services
    ];

    home-manager.users.radu = { config, ... }: {
      home.file."src/mosaic-uxs_mosaic-core-rs/justfile".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wo/justfile";
    };

    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    environment.sessionVariables.PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
      pkgs.openssl.dev
      pkgs.glib.dev
      pkgs.gst_all_1.gstreamer.dev
      pkgs.gst_all_1.gst-plugins-base.dev
      pkgs.gst_all_1.gst-plugins-good.dev
      pkgs.gst_all_1.gst-plugins-bad.dev
      pkgs.gst_all_1.gst-plugins-ugly.dev
      pkgs.gst_all_1.gst-libav.dev
      pkgs.gst_all_1.gst-rtsp-server.dev
      pkgs.gst_all_1.gst-editing-services.dev
    ];

    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
      pkgs.lib.makeSearchPath "lib/gstreamer-1.0" [
        pkgs.gst_all_1.gstreamer.out
        pkgs.gst_all_1.gst-plugins-base.out
        pkgs.gst_all_1.gst-plugins-good.out
        pkgs.gst_all_1.gst-plugins-bad.out
        pkgs.gst_all_1.gst-plugins-ugly.out
        pkgs.gst_all_1.gst-libav.out
        pkgs.gst_all_1.gst-rtsp-server.out
        pkgs.gst_all_1.gst-editing-services.out
      ];

    # nix-ld: lets prebuilt binaries find a dynamic linker
    programs.nix-ld.enable = true;

    # Some tools hardcode /bin/bash, which doesn't exist on NixOS
    systemd.tmpfiles.rules = [ "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" ];

    # Lets tcpdump capture packets without sudo (needs user in `pcap` group).
    programs.tcpdump.enable = true;
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
      text = lib.concatMapStringsSep "\n" clone repos;
    };
  };
}

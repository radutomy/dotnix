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
  flake.modules.nixos.work = { lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      devenv
      direnv
      git
      git-lfs
      just
      lazysql
      ethtool
      usbutils
      arp-scan
      tcpdump
      protobuf
      pkg-config
      nodejs
      electron_43
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

    home-manager.users.radu.programs.fish.interactiveShellInit = lib.mkAfter ''
      function mosaic-dev
        pnpx concurrently -k --kill-signal SIGINT \
          "cd $HOME/src/mosaic-uxs_mosaic-core-rs && cargo run -p mosaic --bin mosaic" \
          "until curl -s http://localhost:8080 >/dev/null 2>&1; do sleep 1; done; pnpm --dir $HOME/src/mosaic-uxs_mosaic-frontend dev"
      end
    '';

    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    environment.sessionVariables.ELECTRON_OVERRIDE_DIST_PATH = "${pkgs.electron_43}/bin";

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

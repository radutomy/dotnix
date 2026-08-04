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
      lazysql
      ethtool
      usbutils
      arp-scan
      tcpdump
    ];

    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    # nix-ld: lets prebuilt binaries find a dynamic linker
    programs.nix-ld.enable = true;
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

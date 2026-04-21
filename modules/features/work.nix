_: {
  flake.nixosModules.work =
    { pkgs, lib, ... }:
    let
      email = "radu.tomuleasa@external.proton.ch";
      name = "Radu Tomuleasa";
      repos = [
        {
          name = "chat-client";
          branch = "develop";
          url = "chat/chat-client";
        }
        {
          name = "monorepo";
          branch = "main";
          url = "proton/clients/monorepo";
        }
        {
          name = "muon";
          branch = "master";
          url = "ProtonVPN/rust/muon";
        }
      ];
      clone = r: ''
        if [ ! -d "$HOME/${r.name}/.git" ]; then
          git clone -b ${r.branch} git@gitlab.protontech.ch:${r.url}.git "$HOME/${r.name}"
          git -C "$HOME/${r.name}" config --local user.email "${email}"
          git -C "$HOME/${r.name}" config --local user.name "${name}"
        fi
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        devenv
        direnv
        git-lfs
        just
        swift-format
      ];

      programs.direnv = {
        enable = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
      };

      # --- monorepo ---

      # nix-ld: lets prebuilt binaries (bazelisk-downloaded bazel) find a dynamic linker
      programs.nix-ld.enable = true;
      # /bin/bash: bazel sandboxes PATH to /bin:/usr/bin:/usr/local/bin, so #!/usr/bin/env bash resolves
      system.activationScripts.binBash.text = "ln -sfn ${pkgs.bash}/bin/bash /bin/bash";

      # ---

      system.activationScripts.workRepos.text = ''
        export PATH=${pkgs.git}/bin:${pkgs.git-lfs}/bin:${pkgs.openssh}/bin:$PATH
        ${lib.concatMapStringsSep "\n" clone repos}
      '';
    };
}

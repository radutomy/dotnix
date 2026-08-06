{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.delta ];

      programs.lazygit = {
        enable = true;
        settings = {
          disableStartupPopups = true;
          git.overrideGpg = true;
          git.diffRenderers = [
            {
              colorArg = "always";
              command = "delta --dark --paging=never --line-numbers";
            }
          ];
        };
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = "Radu T";
            email = "radu@rtom.dev";
            signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev";
          };

          commit.gpgsign = true;
          tag.gpgsign = true;
          gpg.format = "ssh";

          init.defaultBranch = "main";
          pull.rebase = true;
          rebase.autoStash = true;
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";

          core.pager = "delta --dark --paging=never --line-numbers";
          interactive.diffFilter = "delta --color-only";
          delta = {
            navigate = true;
            "line-numbers" = true;
          };
        };
      };
    };
}

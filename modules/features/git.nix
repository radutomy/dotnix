{ self, ... }:
{
  flake.nixosModules.git =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.git-smart-checkout ];

      environment.systemPackages = with pkgs; [ delta ];

      programs.lazygit = {
        enable = true;
        settings = {
          git.overrideGpg = true;
          git.pagers = [
            {
              colorArg = "always";
              pager = "delta --dark --paging=never --line-numbers";
            }
          ];
        };
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
        config = {
          user = {
            name = "radutomy";
            email = "radu@rtom.dev";
            signingkey = "~/.ssh/id_ed25519";
          };

          commit.gpgsign = true;
          tag.gpgsign = true;
          gpg.format = "ssh";

          init.defaultBranch = "main";
          pull.rebase = true;
          rebase.autoStash = true;
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";

          core.excludesFile = "${pkgs.writeText "gitignore" ".codex\n"}";

          core.pager = "delta --dark --paging=never --line-numbers";
          interactive.diffFilter = "delta --color-only";
          delta = {
            navigate = true;
            "line-numbers" = true;
          };

          url."git@gitlab.protontech.ch:".insteadOf = "https://gitlab.protontech.ch/";
        };
      };
    };
}

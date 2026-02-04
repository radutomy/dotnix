{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Radu T";
    userEmail = "radu@rtom.dev";

    signing = {
      key = "/root/.ssh/id_ed25519";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      gpg.format = "ssh";
      tag.gpgsign = true;
      "url \"ssh://git@gitlab.protontech.ch/\"".insteadOf = "https://gitlab.protontech.ch/";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };
  };
}

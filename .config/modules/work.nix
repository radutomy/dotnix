{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  gitlab = "git@gitlab.protontech.ch";
  workEmail = "radu.tomuleasa@external.proton.ch";

  workRepos = [
    { path = "proton/clients/monorepo"; branch = "main"; }
    { path = "chat/chat-client";        branch = "develop"; }
    { path = "rust/proton-rust";        branch = "master"; }
  ];

  cloneRepo = { path, branch }: let dir = baseNameOf path; in ''
    if [ ! -d "${homeDir}/${dir}" ]; then
      git clone --branch ${branch} ${gitlab}:${path}.git "${homeDir}/${dir}"
      git -C "${homeDir}/${dir}" config --local user.email "${workEmail}"
    fi
  '';
in
{
  home.packages = with pkgs; [
    jdk
    glib
    gtk3
  ];

  home.activation.cloneWorkRepos =
    config.lib.hm.dag.entryAfter [ "writeBoundary" ]
      (lib.concatStringsSep "\n" (map cloneRepo workRepos));
}

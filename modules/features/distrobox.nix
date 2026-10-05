_: {
  flake.modules.nixos.distrobox = { config, pkgs, ... }: {
    virtualisation.podman.enable = true;
    environment.systemPackages = [ pkgs.distrobox ];

    environment.sessionVariables.DBX_CONTAINER_HOME_PREFIX = "${config.users.users.radu.home}/.local/share/containers/homes";

    preservation.preserveAt."/persistent".users.radu.directories = [ ".local/share/containers" ];
  };
}

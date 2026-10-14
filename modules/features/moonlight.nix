_: {
  # Remote desktop client for hosts running sunshine.nix
  flake.modules.nixos.moonlight = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.moonlight-qt ];

    preservation.preserveAt."/persistent".users.radu.directories = [
      ".config/Moonlight Game Streaming Project"
    ];
  };
}

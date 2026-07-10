# http://192.168.0.2:3001
_: {
  flake.modules.nixos.invidious = {
    services.invidious = {
      enable = true;
      address = "0.0.0.0";
      port = 3001;

      # sig-helper is disabled: the nixpkgs-packaged binary's regex for
      # extracting YouTube's nsig (anti-throttling) function is stale
      # against YouTube's current player JS and crash-loops on every
      # video. Without it (and without Invidious Companion), video
      # playback is broken; browsing/search still work.
    };

    networking.firewall.allowedTCPPorts = [ 3001 ];
  };
}

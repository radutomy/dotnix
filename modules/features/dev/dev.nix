{ self, ... }: {
  flake.modules.nixos.dev = { pkgs, ... }: {
    imports = [
      self.modules.nixos.gstreamer
      self.modules.nixos.dev-config
    ];
    home-manager.users.radu.imports = [ self.modules.homeManager.dev ];
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5173 ];
  };
}

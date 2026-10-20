_: {
  flake.modules.nixos.nixqs-config = {
    networking.hostName = "nixqs";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];

    home-manager.users.radu = { pkgs, ... }: {
      tmux.layout = "laptop";

      # Only offer Mesa's EGL, so Firefox renders on the Intel GPU like the desktop. Otherwise it
      # picks NVIDIA, and the cross-GPU hand-off freezes it on WebGL pages
      # TODO: (tested broken 2026-10) check if cosmic-comp fixed multi-GPU imports
      # "import for wrong devices" in the journal; if so, remove this and test mosaic's WebGL in Firefox
      programs.firefox.package = pkgs.firefox.overrideAttrs (old: {
        makeWrapperArgs = old.makeWrapperArgs ++ [
          "--set"
          "__EGL_VENDOR_LIBRARY_FILENAMES"
          "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
        ];
      });
    };
  };
}

_: {
  flake.modules.nixos.gstreamer =
    { pkgs, ... }:
    let
      gst = with pkgs.gst_all_1; [
        gstreamer
        gst-plugins-base
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
        gst-rtsp-server
        gst-editing-services
      ];
    in
    {
      environment.systemPackages = gst;
      environment.sessionVariables = {
        PKG_CONFIG_PATH = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" (
          [
            pkgs.openssl
            pkgs.glib
          ]
          ++ gst
        );
        GST_PLUGIN_SYSTEM_PATH_1_0 = pkgs.lib.makeSearchPathOutput "out" "lib/gstreamer-1.0" gst;
      };
    };
}

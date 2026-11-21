{ self, ... }: {
  flake.modules.nixos.nixpc-sunshine =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      steam = lib.getExe config.programs.steam.package;
      edid = pkgs.edid-generator.overrideAttrs {
        clean = true;
        modelines = ''
          Modeline "Sunshine" 594.00 3840 4016 4104 4400 2160 2168 2178 2250 +hsync +vsync
        '';
      };
      tv = pkgs.writeShellApplication {
        name = "sunshine-tv";
        text = ''
          hdmi=/sys/kernel/debug/dri/0000:03:00.0/HDMI-A-1
          plug() {
            echo "$1" | sudo tee "$hdmi/force" > /dev/null
            echo 1 | sudo tee "$hdmi/trigger_hotplug" > /dev/null
          }

          if [ "$1" = on ]; then
            sudo cp ${edid}/lib/firmware/edid/Sunshine.bin "$hdmi/edid_override"
            plug on
          else
            pkill -f "reaper SteamLaunch" || true
            ${steam} -ifrunning steam://close/bigpicture || true
            sleep 2
            plug off
          fi
        '';
      };
    in
    {
      imports = [ self.modules.nixos.sunshine ];

      services.sunshine = {
        openFirewall = true;
        settings.encoder = "vaapi";
        applications.apps = [
          {
            name = "Steam Big Picture";
            image-path = "steam.png";
            prep-cmd = [
              {
                do = "${lib.getExe tv} on";
                undo = "${lib.getExe tv} off";
              }
            ];
            detached = [ "${lib.getExe' pkgs.util-linux "setsid"} ${steam} steam://open/bigpicture" ];
          }
        ];
      };
    };
}

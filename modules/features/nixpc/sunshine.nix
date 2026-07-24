{ inputs, ... }:
{
  flake.modules.nixos.sunshine =
    { pkgs, ... }:
    let
      home = "/home/radu";
      cosCli = "${inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system}}/bin/cos-cli";
      jq = "${pkgs.jq}/bin/jq";
      pgrep = "${pkgs.procps}/bin/pgrep";
      randr = "${pkgs.cosmic-randr}/bin/cosmic-randr";
      rm = "${pkgs.coreutils}/bin/rm";
      steam = "${pkgs.steam}/bin/steam";
      sleep = "${pkgs.coreutils}/bin/sleep";
      systemdRun = "${pkgs.systemd}/bin/systemd-run";
      runSteam = "${systemdRun} --user --collect --quiet --working-directory=${home} ${steam}";
      setMode = pkgs.writeShellScript "sunshine-set-mode" ''
        ${randr} mode "$@" || { ${sleep} 0.1; ${randr} mode "$@"; }
      '';
      streamLayout = pkgs.writeShellScript "sunshine-stream-layout" ''
        set -e
        ${randr} kdl <<'KDL'
        output "DP-1" enabled=#true {
          description make="LG Electronics" model="38GL950G"
          position 0 683
          scale 1.15
          transform "normal"
          adaptive_sync "automatic"
          modes { mode 3840 1600 174971 current=#true }
        }
        output "HDMI-A-2" enabled=#true {
          description make="Invalid Vendor Codename - WAN" model="PM27D-Q95HZ"
          position 3339 0
          scale 1.0
          transform "normal"
          adaptive_sync #false
          modes { mode 1920 1080 60000 current=#true }
        }
        KDL
        ${setMode} DP-1 3840 1600 --refresh 174.971
        ${setMode} HDMI-A-2 1920 1080 --refresh 60.000
        ${randr} xwayland --primary HDMI-A-2
      '';
      openBigPicture = pkgs.writeShellScript "sunshine-open-big-picture" ''
        set -u
        steamState="''${XDG_RUNTIME_DIR:?}/sunshine-started-steam"
        ${pgrep} -x steam >/dev/null || : > "$steamState"
        ${runSteam} steam://open/bigpicture || exit 1

        for _ in {1..40}; do
          if info=$(${cosCli} info --json --discover-wg-output 2>/dev/null); then
            app=$(${jq} -r 'first(.apps[] | select(.app_id == "steam" and ((.title // "") | contains("Steam Big Picture"))) | .index) // empty' <<< "$info")
            output=$(${jq} -r 'first(.outputs[] | select(.name == "HDMI-A-2") | .index) // empty' <<< "$info")
            group=$(${jq} -r 'first(.workspace_groups[] | select(.outputs | index("HDMI-A-2")) | .index) // empty' <<< "$info")
            if [[ -n $app && -n $output && -n $group ]] &&
              ${cosCli} move --index "$app" --workspace 0 \
                --workspace-group "$group" --output-index "$output" &&
              ${cosCli} activate --index "$app"; then
              exit 0
            fi
          fi
          ${sleep} 0.25
        done
        exit 1
      '';
      desktopLayout = pkgs.writeShellScript "sunshine-desktop-layout" ''
        set -e
        ${randr} kdl <<'KDL'
        output "DP-1" enabled=#true {
          description make="LG Electronics" model="38GL950G"
          position 0 683
          scale 1.15
          transform "normal"
          adaptive_sync "automatic"
          modes { mode 3840 1600 174971 current=#true }
        }
        output "HDMI-A-2" enabled=#true {
          description make="Invalid Vendor Codename - WAN" model="PM27D-Q95HZ"
          position 3339 0
          scale 1.15
          transform "rotate90"
          adaptive_sync #false
          modes { mode 2560 1440 94999 current=#true }
        }
        KDL
        ${setMode} DP-1 3840 1600 --refresh 174.971
        ${setMode} HDMI-A-2 2560 1440 --refresh 94.999
        ${randr} xwayland --no-primary

        steamState="''${XDG_RUNTIME_DIR:?}/sunshine-started-steam"
        if [[ -e $steamState ]]; then
          ${runSteam} -shutdown
          ${rm} -f "$steamState"
        else
          ${runSteam} steam://close/bigpicture
        fi
      '';
    in
    {
      services.sunshine = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        capSysAdmin = true;

        settings = {
          sunshine_name = "nixpc";
          capture = "kms";
          output_name = "0"; # HDMI-A-2
          encoder = "vaapi";
          adapter_name = "/dev/dri/renderD128";
          gamepad = "xone";
          hevc_mode = 2;
          av1_mode = 1;
          minimum_fps_target = 60;
        };

        applications.apps = [
          {
            name = "Steam on TV";
            image-path = "steam.png";
            working-dir = home;
            detached = [ "${openBigPicture}" ];
            prep-cmd = [
              {
                do = "${streamLayout}";
                undo = "${desktopLayout}";
              }
            ];
          }
        ];
      };
    };
}

# nas alerts and reports, posted to a Discord channel
let
  webhook = "https://discord.com/api/webhooks/1553402847071178782/FmtrcxIRYEYH5OvjKdKpEKs2eJLgz3rbxOj35AjTBkeI3zj3J-Gui_tO3ktjH3ToglCc";
in
{
  flake.modules.nixos.alerts =
    { lib, pkgs, ... }:
    let
      # Usage: discord "title" ["details"]. Details go in a code block, capped to fit Discord's limit
      discord = pkgs.writeShellScript "discord" ''
        msg=$1
        [ -n "$2" ] && msg+=$'\n```\n'"''${2:0:1800}"$'\n```'
        ${pkgs.curl}/bin/curl -fsS --form-string "content=$msg" ${webhook}
      '';
    in
    {
      # ---- Disk health: smartd posts any problem a drive reports ----
      services.smartd = {
        enable = true;
        notifications.wall.enable = false;
        defaults.autodetected = "-a -m <nomailer> -M exec ${pkgs.writeShellScript "smartd-discord" ''
          ${discord} "$SMARTD_MESSAGE"
        ''}";
      };

      # ---- ZFS pool: problems, plus each monthly scrub result to prove alerts still work ----
      services.zfs.zed.settings = {
        ZED_SLACK_WEBHOOK_URL = "${webhook}/slack";
        ZED_NOTIFY_VERBOSE = true;
      };

      # ---- Service failures: ping with the last log lines when a watched service gives up ----
      systemd.services =
        lib.genAttrs
          [
            "adguardhome"
            "tailscaled"
            "sshd"
            "nfs-server"
            "gdrive"
            "zfs-import-tank"
            "immich-server"
            "immich-machine-learning"
            "postgresql"
            "redis-immich"
            "home-assistant"
          ]
          (_: {
            onFailure = [ "discord-failure@%n.service" ];
          })
        // {
          "discord-failure@" = {
            scriptArgs = "%i";
            script = ''${discord} "@everyone **$1 failed**" "$(journalctl -u "$1" -n 10 -o cat)"'';
          };

          # ---- Startup: every boot, pinging if the last shutdown wasn't clean ----
          nas-started = {
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig.Type = "oneshot";
            # A clean shutdown always ends its log with "Journal stopped"
            script = ''
              last=$(journalctl -b -1 -n 1 -o short-iso)
              seen="''${last:0:10} ''${last:11:5}"
              if [[ $last == *"Journal stopped" ]]; then
                ${discord} "nas started. Previous shutdown was clean (last seen $seen)"
              else
                ${discord} "nas started. @everyone Previous shutdown was NOT clean - power cut or crash (last seen $seen)"
              fi
            '';
          };

          # ---- Weekly digest: Sunday 09:00 health summary ----
          nas-weekly = {
            startAt = "Sun 09:00";
            path = [
              pkgs.zfs
              pkgs.nvme-cli
              pkgs.jq
              pkgs.procps
            ];
            script = ''
              disks=$(for d in /dev/nvme[0-9]; do
                nvme smart-log "$d" -o json | jq -r --arg d "''${d#/dev/}" '"\($d) \(.temperature - 273)°C, \(.percent_used)% worn"'
              done)
              backups=$(journalctl -u gdrive-mirror --since -7d -o cat)
              report=$(cat <<EOF
              uptime      $(uptime -p)
              pool        $(zpool list -H -o health,cap tank | tr '\t' ' ') used, $(zpool status -x)
              last scrub  $(zpool status tank | grep -oP 'scan: \K.*')
              /drive      $(zfs list -H -o used,quota tank/drive | tr '\t' ' ' | sed 's/ / of /')
              OS disk     $(df -h --output=pcent / | tail -1 | tr -d ' ') used
              backups     $(grep -c '^Finished Mirror' <<<"$backups") OK, $(grep -c 'Failed with result' <<<"$backups") failed (last 7 days)
              failed      $(systemctl --failed --no-legend | wc -l) services
              generation  $(readlink /nix/var/nix/profiles/system)
              disks
              $disks
              EOF
              )
              ${discord} "**nas weekly**" "$report"
            '';
          };

          # ---- Nightly /drive backup: what changed, or that it failed ----
          gdrive-mirror = {
            environment.RCLONE_COMBINED = "/tmp/changes";
            serviceConfig.ExecStopPost = pkgs.writeShellScript "drive-discord" ''
              if [ "$SERVICE_RESULT" != success ]; then
                ${discord} "**Drive backup failed** ($SERVICE_RESULT), see: journalctl -u gdrive-mirror"
              elif changes=$(grep -v '^=' /tmp/changes); then
                ${discord} "**Drive backup**" "$changes"
              fi
            '';
          };

          # ---- New LAN devices: every 5 min, post MACs AdGuard has never leased before. The first run only records ----
          lan-new-device = {
            startAt = "*:0/5";
            path = [ pkgs.jq ];
            serviceConfig.StateDirectory = "lan-devices";
            script = ''
              seen=/var/lib/lan-devices/seen
              current=$(jq -r '.leases[] | select(.mac != "00:00:00:00:00:00") | "\(.mac) \(.ip) \(.hostname)"' /var/lib/private/AdGuardHome/data/leases.json)
              if [ -f $seen ]; then
                grep -vFf $seen <<<"$current" | while read -r mac ip name; do
                  ${discord} "New device on LAN: **$name** $ip ($mac)"
                done
              fi
              { cat $seen 2>/dev/null || true; cut -d' ' -f1 <<<"$current"; } | sort -u > $seen.new
              mv $seen.new $seen
            '';
          };

          # ---- Internet outages: check every 30s, post how long it was down once it's back ----
          internet-watch = {
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            path = [ pkgs.iputils ];
            serviceConfig.Restart = "always";
            script = ''
              down=""
              while sleep 30; do
                if ping -c1 -W5 1.1.1.1 >/dev/null || ping -c1 -W5 9.9.9.9 >/dev/null; then
                  [ -n "$down" ] && ${discord} "Internet was down $(date -d @$down +%H:%M)-$(date +%H:%M) ($(( ($(date +%s) - down) / 60 )) min)" && down=""
                elif [ -z "$down" ]; then
                  down=$(date +%s)
                fi
              done
            '';
          };
        };
    };
}

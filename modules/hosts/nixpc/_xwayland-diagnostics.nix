{ pkgs, ... }: {
  # Temporary Dota crash capture
  systemd.tmpfiles.rules = [ "e /var/log/dota-diagnostics - - - 14d" ];
  systemd.services.xwayland-diagnostics = {
    description = "Capture Dota and Xwayland diagnostics";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      procps
      strace
    ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
      LogsDirectory = "dota-diagnostics";
      LogsDirectoryMode = "0700";
    };
    script = ''
      steam=/home/radu/.local/share/Steam
      while sleep 2; do
        dota=$(pgrep -n -u radu -x dota2) || continue
        started=$(date --iso-8601=seconds)
        capture="$LOGS_DIRECTORY/$(date +%Y%m%d-%H%M%S)-$dota"
        mkdir -p "$capture"
        echo "Capturing Dota PID $dota in $capture"
        printf '%s\n' "$started" > "$capture/started"
        {
          uname -a
          readlink -f /run/current-system
          ps -u radu -o pid,ppid,comm,args
        } > "$capture/system.txt"
        cat "/proc/$dota/maps" > "$capture/dota-libraries.txt" || true
        tr '\0' '\n' < "/proc/$dota/environ" \
          | grep -E '^(DISPLAY|WAYLAND_DISPLAY|XDG_SESSION_TYPE|SDL_[A-Z_]+|RADV_[A-Z_]+|MESA_[A-Z_]+|VK_ICD_FILENAMES)=' \
          > "$capture/graphics-environment.txt" || true

        journalctl --follow --lines=100 --output=short-precise > "$capture/journal.log" &
        journal=$!
        tail -n 1000 -F "$steam/logs/console-linux.txt" "$steam/logs/gameprocess_log.txt" \
          > "$capture/steam.log" 2>&1 &
        console=$!
        declare -A traced=()
        tracers=()
        tick=0
        while pgrep -u radu -x dota2 > /dev/null; do
          for pid in $(pgrep -u radu -x Xwayland || true); do
            if [[ ! -v traced[$pid] ]]; then
              ps -p "$pid" -o pid,ppid,comm,args >> "$capture/xwayland-processes.txt" || true
              strace -ttt -s 8192 --trace=write,writev --trace-fds=1,2 \
                --signal='!SIGALRM' -p "$pid" > "$capture/xwayland-$pid.log" 2>&1 &
              tracers+=("$!")
              traced[$pid]=1
            fi
          done
          if ((tick++ % 5 == 0)); then
            {
              date --iso-8601=seconds
              free -m
              cat /proc/pressure/{cpu,memory,io}
              ps -u radu -o pid,ppid,comm,pcpu,pmem,rss \
                | grep -E 'PID|dota|gamescope|Xwayland|cosmic|steam' || true
              for metric in /sys/class/drm/card*/device/{gpu_busy_percent,mem_info_vram_used,mem_info_vram_total} \
                /sys/class/drm/card*/device/hwmon/hwmon*/{temp*_input,fan*_input}; do
                if [ -r "$metric" ]; then
                  printf '%s: ' "$metric"
                  cat "$metric"
                fi
              done
            } >> "$capture/resources.log"
          fi
          sleep 1
        done
        sleep 10
        kill "$journal" "$console" "''${tracers[@]}" 2>/dev/null || true
        wait || true
        coredumpctl --since "$started" --no-pager info > "$capture/coredumps.txt" 2>&1 || true
        date --iso-8601=seconds > "$capture/finished"
        echo "Capture saved in $capture"
      done
    '';
  };
}

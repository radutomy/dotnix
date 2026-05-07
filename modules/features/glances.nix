# http://192.168.0.2:61208
_: {
  flake.nixosModules.glances =
    _:
    let
      sensorAliases = builtins.concatStringsSep "," [
        "Package id 0:0 CPU"
        "Composite 1:1 Fanxiang (nvme0)"
        "Composite 9:2 WD Black (nvme1)"
        "Composite 6:3 WD Black (nvme2)"
        "Composite 3:4 WD Black (nvme3)"
        "Composite:5 Kioxia (nvme4)"
      ];
    in
    {

      environment.etc."glances/glances.conf".text = ''
        [load]
        disable=True

        [outputs]
        max_processes_display=5

        [processlist]
        sort_key=memory_percent
        disable_stats=cpu_num,status,io_counters,username
        disable_virtual_memory=True

        [network]
        hide=lo,ip6tnl0

        [diskio]
        disable=True

        [irq]
        disable=True

        [fs]
        hide=/tmp,/var/log,/var/tmp

        [sensors]
        hide=Sensor.*,acpitz.*,Core.*
        alias=${sensorAliases}
      '';

      services.glances = {
        enable = true;
        openFirewall = true;
        extraArgs = [ "--webserver" "--config" "/etc/glances/glances.conf" ];
      };
    };
}

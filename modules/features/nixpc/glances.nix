{ ... }:
{
  flake.modules.homeManager.glances = { pkgs, ... }: {
    home.packages = [ pkgs.glances ];

    xdg.configFile."glances/glances.conf".text = ''
      [load]
      disable=True

      [mem]
      disable=True

      [memswap]
      disable=True

      [network]
      disable=True

      [connections]
      disable=True

      [diskio]
      disable=True

      [fs]
      disable=True

      [irq]
      disable=True

      [processlist]
      disable=True

      [sensors]
      show=Tctl,edge,junction,mem,VRM MOS,Composite,spd5118 0,CPU Fan,Pump Fan,System Fan #2,amdgpu 0
      alias=Tctl:CPU,edge:GPU,junction:GPU Hotspot,mem:GPU Memory,VRM MOS:VRM,Composite:NVMe,spd5118 0:RAM,System Fan #2:SSD Fan,amdgpu 0:GPU Fan
    '';
  };
}

{ self, lib, ... }:
{
  flake.nixosModules.wsl = _: {
    wsl.enable = true;
    networking.hostName = "wsl";
    system.stateVersion = "25.11";

    programs.ssh.extraConfig = lib.mkAfter ''
      Host nas
        HostName 192.168.0.2
        User root
    '';

    # copies wezterm.lua from this repo to wezterm Windows config folder
    system.activationScripts.weztermCopy = ''
      WIN_USER=$(ls -d /mnt/c/Users/*/AppData | grep -v Default | head -n 1 | cut -d/ -f5)
      install -D ${self.outPath}/wezterm/wezterm.lua "/mnt/c/Users/$WIN_USER/.config/wezterm/wezterm.lua"
    '';
  };
}

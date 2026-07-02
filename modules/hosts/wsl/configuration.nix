{ self, lib, ... }:
{
  flake.nixosModules.wsl =
    { pkgs, ... }:
    {
      wsl.enable = true;
      wsl.interop.register = true;
      networking.hostName = "wsl";
      environment.sessionVariables.HOST_ICON = "󰖳";
      system.stateVersion = "25.11";

      # make /root accessible from native Windows via File Explorer
      users.users.root = {
        group = lib.mkForce "users";
        homeMode = "775";
      };
      system.activationScripts.rootHomePermissions = lib.stringAfter [ "users" ] ''
        chown root:users /root
        chmod 0775 /root
      '';

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

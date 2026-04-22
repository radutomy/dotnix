{ self, lib, ... }:
{
  flake.nixosModules.wsl =
    { pkgs, ... }:
    {
      wsl.enable = true;
      wsl.interop.register = true;
      networking.hostName = "wsl";
      system.stateVersion = "25.11";

      # Horrible work hack!!! Remove when done with TUI
      # WSL has no native browser launcher; wslu provides wslview and the
      # xdg-open shim delegates to it so tools like the `open` Rust crate work.
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "wslview" ''
          target=$1
          [ -e "$target" ] && target=$(/bin/wslpath -w "$target")
          cd /mnt/c
          WSLVIEW_TARGET=$target WSLENV=WSLVIEW_TARGET exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
            -NoProfile -Command 'Start-Process $env:WSLVIEW_TARGET'
        '')
      ];

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

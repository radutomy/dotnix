_:

{
  flake.nixosModules.nas =
    { pkgs, ... }:
    {
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
        };
      };
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
      ];

      services = {
        openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };
      };

      networking = {
        hostName = "nas";
        useDHCP = true;
      };

      environment.sessionVariables.HOST_ICON = "󰒍";
      system.stateVersion = "25.11";
      time.timeZone = "Europe/London";

      # Nested tmux: pane-aware Alt+h/l on the inner session.
      programs.tmux.extraConfig = ''
        bind -n M-h if -F "#{pane_at_left}" "prev" "selectp -L"
        bind -n M-j selectp -D
        bind -n M-k selectp -U
        bind -n M-l if -F "#{pane_at_right}" "next" "selectp -R"
      '';
    };
}

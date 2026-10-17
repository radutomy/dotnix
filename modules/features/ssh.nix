_: {
  flake = {
    modules = {

      nixos.sshd = {
        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
        };
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
        ];
      };

      nixos.sshc = { config, ... }: {
        environment.sessionVariables.SSH_AUTH_SOCK = "${config.users.users.radu.home}/.bitwarden-ssh-agent.sock";
      };

      homeManager.ssh.programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
            ConnectTimeout = 10;
          };
          nas = {
            HostName = "192.168.0.2";
            User = "root";
            ForwardAgent = true;
          };
          "nixpi*" = {
            HostName = "%h.lan";
            User = "root";
            ForwardAgent = true;
          };
        };
      };
    };
  };

}

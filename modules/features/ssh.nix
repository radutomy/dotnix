_: {
  flake.modules.nixos.sshd = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcSG9I0xIYG43LhgnsfR7Y1hOkoVpE5RGSfgr3usDt9 radu@rtom.dev"
    ];
  };

  flake.modules.nixos.sshc = { config, ... }: {
    environment.sessionVariables.SSH_AUTH_SOCK = "${config.users.users.radu.home}/.bitwarden-ssh-agent.sock";
  };

  flake.modules.homeManager.ssh = {
    programs.fish.interactiveShellInit = ''
      if set -q SSH_CONNECTION SSH_AUTH_SOCK; and not set -q TMUX; and test "$SSH_AUTH_SOCK" != ~/.ssh/forwarded-agent
        ln -sfn "$SSH_AUTH_SOCK" ~/.ssh/forwarded-agent
        set -gx SSH_AUTH_SOCK ~/.ssh/forwarded-agent
      end
    '';

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          ConnectTimeout = 10;
        };
        nas = {
          User = "root";
          ForwardAgent = true;
        };
        "nixpi*" = {
          User = "root";
          ForwardAgent = true;
        };
      };
    };
  };
}

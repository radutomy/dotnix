_: {
  flake.modules.nixos.nixpi-config = {
    networking = {
      hostName = "nixpi";
      networkmanager.enable = true;
    };

    users = {
      mutableUsers = false;
      users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3TKS95kYiNDSmdFXcK2NjVCkUVwtgf7YdCaC3eZ3JG rtomuleasa@quantum-systems.com"
      ];
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    time.timeZone = "Europe/London";
    system.stateVersion = "26.05";
  };
}

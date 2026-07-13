{ self, inputs, ... }: {
  flake.nixosConfigurations.nixpc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixpcHardware
      self.modules.nixos.hyprland
      ({ pkgs, ... }: {
        networking = {
          hostName = "nixpc";
          networkmanager.enable = true;
        };

        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        users.users.radu = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          shell = pkgs.fish;
        };

        time.timeZone = "Europe/London";
        i18n.defaultLocale = "en_GB.UTF-8";
        system.stateVersion = "26.05";

        home-manager.users.radu.imports =
          (with self.modules.homeManager; [
            base
            ai
            fish
            git
            nvim
            rust
            tmux
            hyprland
          ])
          ++ [
            (
              { config, pkgs, ... }:
              {
                home.packages = [ pkgs.wezterm ];
                xdg.configFile."wezterm".source =
                  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";
              }
            )
          ];
      })
    ];
  };
}

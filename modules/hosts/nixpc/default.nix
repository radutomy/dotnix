{ self, inputs, ... }:
let
  user = "radu";
  host = "nixpc";

  home = { config, pkgs, ... }: {
    imports = with self.modules.homeManager; [
      base
      ai
      fish
      git
      nvim
      rust
      tmux
      cosmic
    ];

    home.packages = with pkgs; [
      cosmic-ext-applet-sysinfo
      cosmic-ext-applet-weather
      firefox
      wezterm
    ];

    xdg.configFile."wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";
  };

  nixos = _: {
    networking = {
      hostName = host;
      networkmanager.enable = true;
    };

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    services.displayManager.autoLogin = {
      enable = true;
      inherit user;
    };

    users.mutableUsers = false;
    users.users.${user} = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$1wLAffWwSDgcdAyBLVOe3/$JIs2iEJPfTzemMx/EBvfWsJo.MswBJH/ekhyxmANKP9";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };

    security.sudo.extraConfig = "Defaults timestamp_timeout=-1";
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    system.stateVersion = "26.05";
  };
in
{
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.modules.nixos.base
      self.modules.nixos.nixpcDisko
      self.modules.nixos.nixpcHardware
      self.modules.nixos.cosmic
      self.modules.nixos.coolercontrol
      nixos
      {
        home-manager.users.${user} = home;
      }
    ];
  };

  perSystem =
    { pkgs, ... }:
    let
      disko = inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
    in
    {
      apps.nixpc-install.program = pkgs.writeShellApplication {
        name = "nixpc-install";
        runtimeInputs = [
          pkgs.age
          pkgs.git
        ];
        text = ''
          target=$(mktemp -d)

          install -d -m 700 "$target/.ssh"
          git clone -b main https://github.com/radutomy/dotnix "$target/dotnix"
          age -d -o "$target/.ssh/id_ed25519" "$target/dotnix/secrets/ssh_keys.age"
          chmod 600 "$target/.ssh/id_ed25519"
          git -C "$target/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git

          sudo ${disko}/bin/disko-install \
            --flake "path:$target/dotnix#nixpc" \
            --disk main ${self.nixosConfigurations.${host}.config.disko.devices.disk.main.device} \
            --extra-files "$target" /home/${user}
        '';
      };
    };
}

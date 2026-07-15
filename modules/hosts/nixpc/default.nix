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
      firefox
    ];

    home.packages = with pkgs; [
      cosmic-ext-applet-sysinfo
      cosmic-ext-applet-weather
      discord
      simplenote
      chromium
      spotify
      wezterm
    ];

    xdg.userDirs = {
      enable = true;
      createDirectories = false;

      desktop = null;
      documents = null;
      music = null;
      pictures = null;
      projects = null;
      publicShare = null;
      templates = null;
      videos = null;
    };

    xdg.configFile."wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/wezterm";

  };

  nixos = _: {
    networking = {
      hostName = host;
      networkmanager.enable = true;
    };

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
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

    # Ask for the sudo password once per login, not once per terminal, never
    # expire it, and suppress sudo's introductory lecture.
    security.sudo.extraConfig = "Defaults lecture=never, timestamp_timeout=-1, !tty_tickets";
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
      self.modules.nixos.nixpcPreservation
      self.modules.nixos.nixpcHardware
      self.modules.nixos.cosmic
      self.modules.nixos.coolercontrol
      self.modules.nixos.steam
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
          if [ "$EUID" -eq 0 ]; then
            echo "Run nixpc-install without sudo"
            exit 1
          fi

          target=$(mktemp -d)

          install -d -m 700 "$target/.ssh"
          # nix run has already fetched this flake into the Nix store, hence why we have the age key before the git clone
          age -d -o "$target/.ssh/id_ed25519" ${self}/secrets/ssh_keys.age
          chmod 600 "$target/.ssh/id_ed25519"

          git clone -b main https://github.com/radutomy/dotnix "$target/dotnix"
          git -C "$target/dotnix" remote set-url origin git@github.com:radutomy/dotnix.git

          sudo ${disko}/bin/disko-install \
            --flake "path:$target/dotnix#nixpc" \
            --disk main ${self.nixosConfigurations.${host}.config.disko.devices.disk.main.device} \
            --extra-files "$target" /persistent/home/${user}
        '';
      };
    };
}

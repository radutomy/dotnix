{ inputs, ... }:
{
  flake.modules.nixos.nixpcPreservation =
    { config, ... }:
    let
      user = config.services.displayManager.autoLogin.user;
    in
    {
      imports = [ inputs.preservation.nixosModules.default ];

      preservation = {
        enable = true;
        preserveAt."/persistent" = {
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
          directories = [
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            {
              directory = "/var/lib/systemd";
              inInitrd = true;
            }
            "/etc/NetworkManager/system-connections"
            "/var/lib/bluetooth"
            "/var/log"
          ];

          users.${user} = {
            directories = [
              ".ssh"
              ".cargo"
              ".claude"
              ".codex"
              ".cache/nix"
              ".config/mozilla"
              ".config/discord"
              ".local/state/nvim"
              ".local/share/fish"
              ".local/share/nvim"
              ".local/share/Steam"
              ".local/share/zoxide"

              # User Data
              "dotnix"
              "Downloads"
              "src"
            ];
          };

        };
      };

      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
    };
}

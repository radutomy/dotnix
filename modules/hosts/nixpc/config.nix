# Shared desktop config lives in modules/base/desktop.nix
_: {
  flake.modules.nixos.nixpc-config.networking.hostName = "nixpc";
}

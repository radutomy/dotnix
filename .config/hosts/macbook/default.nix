# MacBook configuration
{ ... }:
{
  imports = [
    ../../modules/core.nix
    ../../modules/dev.nix
    ../../modules/gui.nix
  ];

  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };
  home.sessionPath = [ "$HOME/.local/share/pnpm" ];
}

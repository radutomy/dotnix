{ ... }:
{
  imports = [
    ../../modules/core
    ../../modules/dev
    ../../modules/gui
  ];

  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };
  home.sessionPath = [ "$HOME/.local/share/pnpm" ];
}

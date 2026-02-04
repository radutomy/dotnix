{ ... }:
{
  imports = [
    ../../modules
    ../../modules/git.nix
    ../../modules/zsh.nix
    ../../modules/rust.nix
  ];

  home.sessionVariables.PNPM_HOME = "$HOME/.local/share/pnpm";
  home.sessionPath = [ "$HOME/.local/share/pnpm" ];
}

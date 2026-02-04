# Development tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustc cargo rust-analyzer rustfmt clippy
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
}

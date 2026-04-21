_: {
  flake.nixosModules.rust =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        cargo
        cargo-binstall
        clippy
        rust-analyzer
        rustc
        rustfmt
      ];
    };
}

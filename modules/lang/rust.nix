_: {
  flake.modules.homeManager.rust =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cargo
        cargo-binstall
        clippy
        rust-analyzer
        rustc
        rustfmt

        # Others
        rustlings
      ];
    };
}

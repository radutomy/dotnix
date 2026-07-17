# COSMIC panel applet showing usage limits for Codex, Claude Code, and Cursor.
{ self, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.yapcap = pkgs.rustPlatform.buildRustPackage {
      pname = "yapcap";
      version = "0.5.2";

      src = pkgs.fetchFromGitHub {
        owner = "TopiCsarno";
        repo = "yapcap";
        tag = "v0.5.2";
        hash = "sha256-81puxfUV+aWznrX/4jt5HCYFHVNlcc0aVGDm9bahEVQ=";
      };
      cargoHash = "sha256-KMEndi5OCaAE/4BXQi7kFjqeXuEIm+wnOkJ69qMF19k=";

      nativeBuildInputs = with pkgs; [
        just
        libcosmicAppHook
        pkg-config
      ];
      buildInputs = [ pkgs.openssl ];

      dontUseJustBuild = true;
      dontUseJustCheck = true;
      # demo_env tests expect a writable home, absent in the sandbox
      doCheck = false;
      justFlags = [
        "--set"
        "prefix"
        (placeholder "out")
        "--set"
        "cargo-target-dir"
        "target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}"
      ];
    };
  };

  flake.modules.homeManager.yapcap = { pkgs, ... }: {
    home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.yapcap ];
  };
}

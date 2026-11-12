# TODO: (tested broken 2026-11) delete this file once nixpkgs updates Glances to 4.5.9 or later and replaces python-jose with PyJWT
_: {
  flake.modules.nixos.base = {
    nixpkgs.overlays = [
      (_: prev: {
        glances = prev.glances.overridePythonAttrs (old: {
          version = "4.5.9";
          src = prev.fetchFromGitHub {
            owner = "nicolargo";
            repo = "glances";
            tag = "v4.5.9";
            hash = "sha256-CvT9GQ29xXTVxC7V2nGmfDhHLsAtF61+XMMLG8cmHww=";
          };
          dependencies = builtins.filter (dep: (dep.pname or "") != "python-jose") old.dependencies ++ [
            prev.python3Packages.pyjwt
          ];
          nativeCheckInputs = old.nativeCheckInputs ++ [ prev.python3Packages.pysmart ];
        });
      })
    ];
  };
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    claude-code.url = "github:sadjow/claude-code-nix";
    codex.url = "github:sadjow/codex-cli-nix";
    gemini-cli.url = "github:sadjow/gemini-cli-nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}

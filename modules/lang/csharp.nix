_: {
  flake.nixosModules.csharp =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        dotnet-sdk_11
        csharpier # Formatter
        netcoredbg # Debugger for nvim-dap
        roslyn-ls # Modern Microsoft LSP
      ];
    };
}

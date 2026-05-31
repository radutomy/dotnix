_: {
  flake.modules.homeManager.csharp =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dotnet-sdk_11
        csharpier # Formatter
        netcoredbg # Debugger for nvim-dap
        roslyn-ls # Modern Microsoft LSP
      ];
    };
}

_: {
  flake.modules.homeManager.fish = { pkgs, ... }: {
    programs = {
      fzf.enable = true;

      zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
      };

      fish = {
        enable = true;
        # Overwrite comma so it also runs unfree packages
        functions."," = ''
          if command , -p $argv[1] &>/dev/null; command , $argv; return; end
          NIXPKGS_ALLOW_UNFREE=1 nix run --impure "nixpkgs#$argv[1]" -- $argv[2..-1]
        '';
        plugins = [
          {
            name = "autopair";
            src = pkgs.fishPlugins.autopair.src;
          }
          {
            name = "hydro";
            src = pkgs.fishPlugins.hydro.src;
          }
        ];

        shellInit = ''
          function fish_title; prompt_pwd; end

          set fish_prompt_pwd_dir_length 100 # max length of dir path
          set fish_greeting # surpress fish greeting
          set hydro_color_pwd green
          set hydro_color_git brblack
          set hydro_color_prompt white

          fish_add_path ~/.cargo/bin
        '';

        interactiveShellInit = ''
          bind \ce 'clear; commandline -f repaint'
          function __auto_ls --on-variable PWD
            lsd -F
          end
        '';
      };
    };
  };
}

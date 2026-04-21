_: {
  flake.nixosModules.fish =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        fishPlugins.autopair
        fishPlugins.hydro
        lsd
      ];

      users.defaultUserShell = pkgs.fish;

      programs = {

        zoxide = {
          enable = true;
          flags = [ "--cmd cd" ];
        };

        fzf = {
          fuzzyCompletion = true;
          keybindings = true;
        };

        fish = {
          enable = true;
          shellInit = ''
            set fish_prompt_pwd_dir_length 100 # max length of dir path
            set fish_greeting # surpress fish greeting
            set hydro_color_pwd green
            set hydro_color_git 808080
            set hydro_color_prompt white
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

_: {
  flake.modules.homeManager.tmux =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.tmux.layout = lib.mkOption { default = "default"; };
      config = {
        home.packages = [ pkgs.tmux ];

        # Symlink the repo's tmux config into ~/.config
        xdg.configFile."tmux".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/tmux";

        programs.fish.interactiveShellInit = lib.mkAfter ''
          # One tmux client at a time: a new terminal or SSH login takes the session over (-D)
          if not set -q TMUX
            tmux has-session 2>/dev/null; or tmux start-server \; source-file ~/dotnix/tmux/layouts/${config.tmux.layout}.conf
            exec tmux new-session -AD -s main
          end
        '';
      };
    };
}

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
          if not set -q TMUX; and not tmux list-clients 2>/dev/null | string match -qr .
            tmux has-session 2>/dev/null; or tmux start-server \; source-file ~/dotnix/tmux/layouts/${config.tmux.layout}.conf
            exec tmux new-session -A -s main
          end
        '';
      };
    };
}

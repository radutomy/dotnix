_: {
  flake.modules.homeManager.tmux =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Percentage pane dimming is implemented upstream but not in tmux 3.7b.
      tmux = pkgs.tmux.overrideAttrs {
        version = "next-3.8";
        src = pkgs.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "15746a1bc796a76cd855636e0073c339b517b1c2";
          hash = "sha256-0BNdaU79Kj2URxGzyGgyp0XLKVxI3M3YEs0btAe3lwE=";
        };
      };
    in
    {
      # plain package instead of programs.tmux so HM doesn't generate its own
      # tmux.conf over the repo's config symlinked below
      home.packages = [ tmux ];

      # Symlink the repo's tmux config into ~/.config
      xdg.configFile."tmux".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotnix/tmux";

      programs.fish.interactiveShellInit = lib.mkAfter ''
        # skip if already inside tmux (prevents recursive session creation in new panes)
        if not set -q TMUX
          cd ~
          tmux attach 2>/dev/null; and exit
          tmux new-session -d -s main -n core
          # tmux split-window -h
          # tmux select-pane -L
          # tmux new-window -n heap
          # tmux split-window -h
          # tmux select-pane -L
          # tmux new-window -n kernel
          # tmux split-window -v
          # tmux select-pane -U
          tmux new-window -n stack
          tmux new-window -n cache -c ~/dotnix
          tmux split-window -h -p 30 -c ~/dotnix
          tmux split-window -v -p 25 -c ~/dotnix
          tmux select-pane -L
          tmux select-window -t 0
          exec tmux attach
        end
      '';
    };
}

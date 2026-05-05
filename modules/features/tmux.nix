_: {
  flake.nixosModules.tmux =
    { lib, ... }:
    {
      programs.tmux.enable = true;
      # Symlink the repo's tmux config into ~/.config
      systemd.tmpfiles.rules = [ "L+ %h/.config/tmux - - - - %h/dotnix/tmux" ];

      programs.fish.interactiveShellInit = lib.mkAfter ''
        # skip if already inside tmux (prevents recursive session creation in new panes)
        if not set -q TMUX
          cd ~
          tmux attach 2>/dev/null; and exit
          tmux new-session -d -s main -n core
          tmux split-window -h
          tmux select-pane -L
          tmux new-window -n heap
          tmux split-window -h
          tmux select-pane -L
          tmux new-window -n kernel
          tmux split-window -v
          tmux select-pane -U
          tmux new-window -n stack
          tmux new-window -n cache -c ~/dotnix
          tmux split-window -h -c ~/dotnix
          tmux split-window -v -p 25 -c ~/dotnix
          tmux select-pane -L
          tmux select-window -t 0
          exec tmux attach
        end
      '';
    };
}

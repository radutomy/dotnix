# Radu's Opinions

## Engineering

- Do not sacrifice long-term quality to reduce implementation effort.

## Configuration

- Prefer declarative configuration (I love Nix) and native platform capabilities over custom scripts and services.
- Keep configuration compact, readable, and explicit.
- Keep one source of truth rather than duplicating configuration.
- Avoid adding dots (.) at the end of a code comment
- In dotnix, write file paths relative to the file (`../../../secrets/x.age`)
- In dotnix, refer to programs as `lib.getExe pkgs.x`, or `lib.getExe' pkgs.x "name"` when it is not the package's main program

## Development Environment

- Prefer terminal-centered workflows with grep, fzf, Neovim-style editing, and low visual clutter.

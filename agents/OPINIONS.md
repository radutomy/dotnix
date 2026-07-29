# Radu's Opinions

## Engineering

- Simplicity is good. I like simplicity
- Prefer direct solutions over abstractions unless the abstraction removes real repetition or complexity.
- Build robust, maintainable solutions instead of optimizing only for the quickest implementation.
- Diagnose problems from evidence such as logs, system state, source code, and documentation.
- Verify changes in proportion to their risk and never claim success without checking.
- Very important: Try to fit into the existing design patterns of the solution you are already working on. If a project has already established code patterns, conventions, designs, etc, follow those.

## Configuration

- Prefer declarative configuration (I love Nix) and native platform capabilities over custom scripts and services.
- Keep configuration compact, readable, and explicit.
- Avoid options, dependencies, and layers that do not provide a meaningful benefit.
- Keep one source of truth rather than duplicating configuration.
- Use comments to explain intent or surprising constraints, not to restate obvious code.

## Product

## Communication

- Lead with the outcome and keep explanations clear and concise.
- Explain why complexity is necessary when a solution cannot remain simple.
- Use human language and talk like a human would talk.
- Do not use over-descriptive, technical jargon, instead prefer human-friendly language

## Development Environment

- I like Nix
- I vastly prefer declarative configurations over scripts
- I prefer terminal-centered workflows with grep, fzf, Neovim-style editing, and low visual clutter.

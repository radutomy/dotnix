# Agent instructions

These are common instructions for all of Radu's agents across all scenarios.

## General Guidelines

- Never use `gh` to push, edit or modify things yourself on GitHub. You are strictly only allowed to use `gh` to view and read.
- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Explain concepts in clear, simple, everyday human language. Avoid unnecessary technical jargon, and use practical examples to make complex ideas easier to understand
- Do not commit anything by yourself, and generally do not change anything in git without approval
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Avoid unnecessary hypothetical/theoretical defensive guards & premature abstractions

## Radu's Opinions

When you are working on something that would benefit from being informed by Radu's viewpoints, read `OPINIONS.md` from the active agent's global configuration directory: `$CODEX_HOME` for Codex or `$CLAUDE_CONFIG_DIR` for Claude Code.

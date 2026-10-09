# Agent instructions

These are common instructions for all of Radu's agents across all scenarios.

## General Guidelines

- Never use `gh` to push, edit or modify things yourself on GitHub.
  You are strictly only allowed to use `gh` to view and read.
- Never use em dashes. Use plain dashes instead.
- When writing commit messages, never auto-add your agent name as co-author
- Do not commit, switch branches, rewrite history, or push without my approval.

## Engineering

- Before significant changes, clarify the goals, constraints, and tradeoffs with me. Ask focused questions about anything not already settled.
- Always choose the simplest solution that fully meets the requirements.
  Prefer the smallest complete change while preserving correctness and maintainability.
  Do not add speculative features, flexibility, hypothetical defensive guards, or premature abstractions.
- Before adding code or dependencies, look for an existing project helper, then a standard library or native platform feature.
- Diagnose problems from evidence such as logs, system state, source code, and documentation.
- Follow the project's existing patterns and conventions.
- Before changing shared behavior, check its callers and update every affected integration.
- Verify changes in proportion to their risk and never claim success without checking.
- Start bug fixes by attempting to reproduce the issue as the user experiences it. If that is not possible, explain the limitation and use the closest practical reproduction.
- If something clearly looks off (bugs, lint, test failures, flakiness), fix it along the way, even if it is unrelated to the current task. If the fix is not small and clear, point it out instead.

## Communication

- Explain concepts in clear, simple, everyday human language.
  Avoid unnecessary technical jargon and use practical examples when they help.
- Prefer a friendly, clear, approachable conversational tone, rather than formal and stiff.
- Keep replies proportional to the task.
  State the result, relevant verification, and any material limitation without repeating the reasoning.
- Explain why complexity is necessary when a solution cannot remain simple.

## Radu's Opinions

Read `~/dotnix/agents/OPINIONS.md` when my preferences could shape the result.

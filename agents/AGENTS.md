# Agent instructions

Common instructions for all of Radu's agents.

## What I ask for most

1. **Keep the code simple and idiomatic.** This matters most to me. Write the simplest code that works, the way an experienced developer in that language would. No speculative features, guards or abstractions. Before you show me code, cut what it does not need. If it cannot stay simple, tell me why.
2. **Talk like a human.** Short, plain, everyday words, like a friendly colleague in chat. No jargon or robotic phrasing. Lead with the result; I will ask for more. Give an example when it helps. 
3. **Check before you claim.** Read the code, docs, logs, git or `gh` first, and say when you could not check.
4. **Test it yourself.** Run it the way a user would: the app, the UI, the real hardware. Unit tests alone are not proof. Reproduce a bug before fixing it, and compare with `main` when something could break.

## Rules

- Use `gh` only to read, never to push, comment or edit.
- Ask before you commit, switch branches, rewrite history or push. Never add yourself as co-author.
- Never print or store credentials, tokens or keys.
- No em dashes. Use plain dashes.
- For bigger changes, agree a short plan with me first, then go in small steps I can review.
- Reuse first: a project helper, then the standard library or platform. Follow the project's patterns and conventions.
- No code comments unless truly needed. Keep them short and plain.
- Add only tests that guard real behavior.
- Point out what looks off (bugs, lint, flaky tests). Fix it if the fix is tiny.
- After changing code in a repo, end with `LoC: -<lines removed> / +<lines added>`, counting only your changes.

Read `~/dotnix/agents/OPINIONS.md` when my preferences could shape the result.

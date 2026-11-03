# dev-agent-template

A lean setup for web and mobile developers who work with coding agents.
It installs a good terminal, Claude Code and a one-agent-per-worktree workflow,
and keeps the agent's context small so the agent stays sharp.

> Status: early. macOS only for now.

## What you get

| Piece | What it does |
| --- | --- |
| **Ghostty** + `config/ghostty/config` | Fast terminal. Shift+Enter works out of the box. Splits on `cmd+d` / `cmd+shift+d`, move with `cmd+alt+arrows`, zoom a pane with `cmd+shift+enter`. |
| **Claude Code** | Native installer. |
| **`wt`** | `wt <branch>` creates a git worktree next to your repo, copies your `.env*` files, and starts Claude in it. `wt ls`, `wt rm <branch>`. |
| **`claude-notify`** | macOS notification naming the project when an agent finishes or needs you. |
| **Global `CLAUDE.md`** | About 15 lines: definition of done, git rules, how to grow skills. Only installed if you don't already have one. |
| **Settings** | No commit attribution, read-only git/gh commands and lint/test/build pre-approved, notification hooks. **Merged** into your existing `settings.json`. Your values win, and a backup is made. |
| **tmux, gh, fnm, jq** | Multiplexer, GitHub CLI, Node version manager, JSON tool. |

## Install

```sh
gh repo clone notagainsaray/dev-agent-template   # or download the ZIP from GitHub
cd dev-agent-template
./setup.sh --dry-run   # see what it would do
./setup.sh
```

Then open Ghostty, run `claude` once to sign in, and you're set.
You can safely run it again: anything already done is skipped.

> **On a work laptop:** check that Ghostty and Claude Code are approved, and sign in with your company Claude account.

## Daily workflow

1. **One main agent per repo.** Open Ghostty, `cd` into the repo, run `claude`.
   For side jobs like searching, planning or reviewing, let Claude use sub-agents. They keep file dumps out of your main context.
2. **Parallel work = parallel worktrees.** When two tasks are truly independent, split the pane (`cmd+d`) and run `wt feature-x` in the new pane.
   Each agent gets its own checkout and branch, so agents never edit each other's files.
   Install dependencies inside a new worktree before running checks.
3. **Wait for the ping.** `claude-notify` tells you which project is done or waiting.
4. **Clean up.** `wt rm feature-x` after merging. It refuses if there's uncommitted work.

## Growing your agent setup

The rules below come from the research in [`research/`](research/):

- **Keep `CLAUDE.md` / `AGENTS.md` short.** They load on every turn. Don't describe your stack, because the agent can read the code. Only write down what it can't see: definition of done, commands, team conventions.
- **Earn your skills.** Do a workflow with the agent by hand until it succeeds. Then ask it to *"review what you just did and write a skill"*. Skills only cost their name and description until they're used, so a precise `description` matters most.
- **Improve skills from failures.** When a skill fails, ask the agent why, let it fix the problem, then say *"update the skill so this doesn't happen again"*.
- **Add sub-agents last.** Start with one agent. Add a specialised sub-agent only when a whole area, like releases or design review, has proven workflows. Scale for productivity, not for what looks cool.
- **Watch the context.** Quality drops as the window fills. Use `/compact` or `/clear` between tasks.
- **Be careful with downloaded skills, agents and MCP servers.** Read them before you install them.

## Roadmap

- [ ] Web starter (project `AGENTS.md`, checks, example skill-capture flow)
- [ ] Mobile starter (iOS/Android release workflow as a skill)
- [ ] Linux support
- [ ] tmux layout for people who don't use Ghostty splits

## License

MIT

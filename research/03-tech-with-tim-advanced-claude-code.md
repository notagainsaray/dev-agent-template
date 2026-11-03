# Source 03 — "Claude Code: The Advanced Guide (99% of Devs Skip These Features)"

- **Video:** https://www.youtube.com/watch?v=kt5a-TXmWew
- **Who:** Tech With Tim (Tim Ruscica). 19:38, published 2026-09-07. Sponsored segments for Granola (the MCP part) and Wispr Flow.
- **Collected:** 2026-11-03 from the transcript (auto captions) and the description's chapters

## Claims made in the video

Nine features, each with a short demo.

1. **Custom sub-agents.** Put markdown files in `.claude/agents/`. Each has a name, description, allowed tools and, optionally, a model. A cheaper model cuts cost when you run many. His examples: `reviewer` and `debugger`. `/context` shows they are loaded. "Review this PR before I merge it" picked the reviewer on its own. Only the sub-agent's answer comes back to the main thread, so the main thread stays lean and accuracy holds. Create one only when you want work out of the main thread, or fixed rules such as read-only tools or a set model.
2. **Skills, with two lesser-known options.** Skills live in `.claude/skills/`. You write them, ask the agent to write them, or import them from GitHub. Only the name and description are seen before the skill is used.
   - `disable-model-invocation: true` stops the model from loading the skill by itself. It shows as locked in `/skills` and runs only when you type it. His example: `/rollback`.
   - Skills take arguments: `/deploy staging`.
3. **Hooks.** Run a shell command on agent-loop events: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse and others. His config:
   - PostToolUse on `Edit|Write` runs a format script. Prettier reformatted the whole file after the edit.
   - PreToolUse runs a "block dangerous" script. Exit code 2 blocks the tool call.
4. **MCP servers** connect external tools. The only demo is the sponsor, Granola: it pulled his latest meeting transcript (an Indonesian lesson). No general MCP advice.
5. **Worktrees.** "Effectively essential" for parallel agents, so they don't change each other's files. Claude sometimes makes them by itself, but making them yourself is "best practice": `claude --worktree fix-delete-bug` in one terminal, `claude --worktree feature-dark-mode` in another, both in auto mode. Afterwards a third session, not in a worktree, found both worktrees' changes and merged them.
6. **Headless mode.** `cat build.log | claude -p "why did this fail?"` answers without opening the UI.
   - `--output-format json` + `jq` gives a result plus cost, number of turns and duration in ms. Cost is meaningless on a subscription.
   - `--allowedTools Read` limits what it can touch.
   - He shows a triage script built on this, but doesn't run it.
7. **Checkpoints and rewind.** He broke a tip-calculator app on purpose, then used `/rewind` → pick an earlier prompt → "restore code and conversation". The app worked again.
8. **Continue a session.** `claude --continue` reopens the last conversation in that folder. Sessions are saved on disk with IDs you can resume from any directory.
9. **Name and branch sessions.**
   - `claude -n auth-refactor` names a session. The name shows in the status line. `claude --resume auth-refactor` goes back to it.
   - `/branch` forks the conversation without overwriting the original. He used it to try a risky "rewrite the module as a class with static methods", then went back to the pre-branch session with `/resume`.
10. "99% of devs skip these" and "most people don't know" are hype, not measured.

## How it fits with sources 01–02

- **Agrees with 01 and 02 on sub-agents.** They keep the main context lean, and accuracy drops as the window fills.
- **Adds the permanent kind of sub-agent.** 02 was about throwaway sub-agents. Tim's reviewer and debugger are the permanent custom agents that 01 says to add slowly. They don't really clash: a reviewer is a common, proven workflow, so it is a reasonable first one. A starter roster of many is still a no.
- **Conflicts with 01 on imported skills.** Tim lists "import from a GitHub repo" as a normal way to get skills. 01 says don't install other people's skills: they lack your context and are a security risk. Our README already sides with 01.
- **Skills by hand or by agent.** He doesn't mention 01's "do it once, then write the skill from the successful run". Not a conflict, just a gap.
- **Worktrees match our approach.** One agent per worktree is already core to the template. The built-in `claude --worktree` overlaps with our `wt` script (see below).
- **Merging is looser than our rules.** A plain session in auto mode merged both worktrees. Our CLAUDE.md says never commit unless asked. Merging is a step to review yourself, not one to wave through in auto mode.
- **New ground that 01 and 02 don't cover:** hooks, headless mode, rewind, named and branched sessions. 01's pushback noted that hooks and worktrees needed other sources. This is one.

## What it means for the template

- **Mark side-effect skills as manual only.** Any skill that deploys, releases, rolls back or migrates gets `disable-model-invocation: true`. Add one line to the Skills section of `config/claude/CLAUDE.md`, and use it in the planned mobile release skill. Bonus: a locked skill also stays out of the always-loaded context.
- **Turn the git rules into a hook, not just text.** Ship an optional PreToolUse guard (exit 2) that blocks `git push --force`, commits on `main` and `rm -rf` outside the repo. A rule in CLAUDE.md can be ignored; a hook can't. Keep it opt-in in `setup.sh` and merge it like the notify hooks.
- **Offer a formatter hook, but opt in.** PostToolUse on `Edit|Write` → run the project's own formatter only if it has one (Prettier, SwiftFormat, ktlint). Whole-file reformatting makes noisy diffs in repos that aren't already formatted, so it must not be on by default.
- **Decide what `wt` is for now that `claude --worktree` exists.** `wt` still adds value: it copies `.env*` files, puts the checkout next to the repo, reuses an existing worktree and refuses to remove one with uncommitted work. Say this in the README, so people don't think it's reinventing the built-in. Check whether the built-in now copies ignored files (for example through a `.worktreeinclude` file). If it does, `wt` could wrap it instead.
- **Add a "Sessions" part to the daily workflow.** `/rewind` to undo a bad turn, `/branch` before a risky experiment, `-n`/`--resume <name>` for long tasks, `--continue` after a restart. This sits next to the existing `/compact` and `/clear` advice.
- **Add a headless example to the web starter.** Something like a `scripts/triage-build.sh` that pipes a failed build log to `claude -p --output-format json --allowedTools Read`. It is useful in CI and shows read-only use.

## Where I'd push back or add nuance

- **Hooks config location.** He describes "a hooks folder with a settings.json". Hooks are set in `.claude/settings.json` (or the user settings). The scripts they call can live anywhere, often `.claude/hooks/`. Small slip, but people copying it will get confused.
- **Auto mode everywhere.** Every demo flips to auto mode to save time. Fine for a demo repo. On real work, and especially for merges, it removes the review step our template relies on.
- **"Worktrees work better than branches."** A worktree is a separate checkout of a branch, not an alternative to one. The real point: each agent gets its own folder.
- **Rewind isn't version control.** It restores files Claude edited, not changes made by shell commands or outside the session. Commit (or stash) before risky work anyway.
- **Session flags change fast.** `-n`, `/branch` and `/resume` behaviour should be checked against `claude --help` for the installed version before we put exact commands in the README.
- **The MCP section is an ad.** It says nothing about choosing, trusting or scoping MCP servers. Our "read them before you install them" note stands.
- **Cost of custom sub-agents.** A model per agent can cut cost, but each sub-agent still starts cold and re-reads files. For small jobs, 02's "do it directly" still applies.

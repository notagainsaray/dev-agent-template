# Synthesis: the approach this template takes

Living document. Each new source either confirms a decision here or changes one line.
Sources so far:

- **01** Ras Mic (Greg Isenberg podcast): context, skills, scale slowly.
- **02** Charlie Automates (+ Boris Cherny's tips): sub-agents, parallel vs sequential.
- **03** Tech With Tim: advanced features: custom agents, hooks, worktrees, headless, sessions.
- **04** Hustle Badger: 12 PRD templates compared; PRDs are communication tools.

Last updated 2026-11-03. CLI flags checked against Claude Code 2.1.317.

## Decisions

| # | Question | 01 | 02 | 03 | **Decision** |
| --- | --- | --- | --- | --- | --- |
| 1 | How big should CLAUDE.md be? | Minimal; "95% don't need it" | Contains the sub-agent strategy | — | **Short (≈25 lines).** Only what the agent can't see in the code: definition of done, git rules, delegation rules. Never describe the stack. |
| 2 | Where do skills come from? | Built from your own successful runs; don't install others' | — | Imports from GitHub as normal | **Build your own.** Read third-party skills for ideas; never install them unread. 01 wins: a skill without your run's context is guesswork, and downloads are an attack surface. |
| 3 | Skills with side effects? | — | — | `disable-model-invocation: true` → only runs when typed | **Deploy / release / rollback / anything outward-facing = manual-only.** Skills take arguments (`/deploy staging`). |
| 4 | Throwaway sub-agents (one task) | Use them | Use on purpose; parallel vs sequential | Only the answer returns | **Use freely for "read a lot, return a little"**: search, long docs, logs, reviews. Parallel when independent, sequential when each step feeds the next. Do small jobs directly. |
| 5 | Should Claude ask how to split work? | — | Always ask on multi-step tasks | — | **Only for big multi-part requests.** Asking every time adds a question to nearly every request. |
| 6 | Permanent custom agents (`.claude/agents/`) | Add one only after a whole area has proven workflows | — | Own tools + model per agent | **Ship none.** Document how to add one (narrow tools, cheaper model where it fits) once a workflow is proven. 01 and 03 agree: the question is *when*, not *whether*. |
| 7 | Parallel agents | One agent first | — | `claude --worktree` per agent is essential | **One agent per worktree**, only for truly independent tasks. `wt` is a thin wrapper around `claude --worktree` (decided 2026-11-03, see A). |
| 8 | Merging parallel work | — | — | A separate session merges, in auto mode | **Merge through review (PR or diff read), never auto.** Auto merging skips the one check that catches agents stepping on each other. |
| 9 | Hooks | — | — | Formatter after edits; guard script blocks dangerous commands (exit 2) | **Ship `claude-guard`**: blocks **every** `git push`, commits on main/master, and recursive `rm` outside the repo, so the git rules are enforced, not just written (see B). Formatter hook is per project, opt-in. Keep the notify hook. |
| 10 | Context hygiene | Stay under ~70%; models degrade as it fills | Sub-agents keep it clean | `/rewind`, `/branch`, named sessions | **README section:** `/clear` between tasks, `/compact` mid-task, `/rewind` to undo code + conversation, `-n` to name and `-r` to resume sessions, `/branch` for risky experiments. |
| 11 | Headless / scripts | — | — | `claude -p --output-format json`, `--allowedTools` to restrict | **Later:** CI recipes (review a PR, triage a failing build) with read-only tools. |
| 12 | Terminal | — | — | — | **Ghostty** (our call, no source covers it). Splits for panes; tmux as the portable fallback. |
| 13 | PRD format | — | — | — | **One page by default (04).** Linear's Context / Usage scenarios / Milestones at the core, the rest optional, impact reviewed after launch. The `/prd` skill asks who reads it first and reviews it from several personas. |

## Decided

- **A. `wt` vs `claude --worktree` → slim `wt` into a wrapper** (2026-11-03). Tested on 2.1.317:
  - `claude -w <name>` creates `.claude/worktrees/<name>` on branch `worktree-<name>` and reuses it by name.
  - It copies files listed in `.worktreeinclude`.
  - It leaves a `claude session … (pid N)` lock after it exits.

  So `wt`:
  - adds `.worktreeinclude` (`.env*`);
  - hides `.claude/worktrees/` through `.git/info/exclude`;
  - and on `rm` clears only stale Claude locks.
- **B. Guard strictness → block every `git push`** (2026-11-03). Agents may commit on a branch. The user always pushes.
  - **Two layers:** a `deny: Bash(git push:*)` rule in settings.json, so push stays blocked even if the hook breaks, plus the `claude-guard` regex for forms the prefix rule misses (`git -C x push`).
  - **Fails closed:** if `jq` is missing, the guard blocks everything.
- **Candidate:** Claude Code's sandbox (`sandbox.enabled`) instead of the best-effort `rm` check. The operating system would then enforce "no writes outside the repo", but the sandbox also limits network access. Test it on a real project before making it the default.

- **C. Review and docs hygiene** (2026-11-03, own decision):
  - Sub-agents never commit, and every commit comes after the user has seen the diff.
  - Each project's AGENTS.md has a **Verified commands** table, which is its definition of done (`templates/AGENTS.md`).
  - Agent docs carry no stale lines, and changes to them are proposed, not made silently.

## Agreed across all sources

1. The model is good. What you put in its context decides the quality.
2. Keep the main session lean. Delegate big reads.
3. Grow slowly: one agent → skills from real runs → sub-agents → permanent agents.

## Not covered yet (look for these in the next sources)

- **MCP servers**: 03's section was only an ad. When to add one, how to vet it, its context cost.
- **Permissions strategy**: allow / ask / deny lists, auto mode, sandboxing.
- **Teams**: what to commit in `.claude/`, shared skills and agents, onboarding.
- **Web starter** and **mobile starter**: project AGENTS.md, checks, release workflow as a skill.
- **Cost**: plans vs API, model choice per sub-agent.

## Template changes this implies (in order)

1. ✅ Sub-agent section + manual-only side-effect skills in `config/claude/CLAUDE.md` (decisions 3–5).
2. ✅ `bin/claude-guard` + PreToolUse hook (decision 9, B).
3. ✅ README: Sessions and context section (decision 10), review then you push (decision 8).
4. ✅ Slim `wt` on top of `claude --worktree` (A).
5. Add `/capture-skill` and `/update-skill` commands (decision 2: the method, not pre-made skills).

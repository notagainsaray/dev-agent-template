# Source 01 — How AI agents & Claude skills work (Clearly Explained)

- **Video:** https://www.youtube.com/watch?v=S_oN3vlzpMw
- **Who:** Greg Isenberg interviewing Ras Mic. 35 min, published 2026-04-08.
- **Collected:** 2026-11-02 from the transcript (auto captions)

## Claims made in the video

1. **The models are good now, so context and harness are what make the difference.** The harness and what you put into context decide quality vs slop. He cites a benchmark where the same model gave different results in Cursor, Claude Code and Codex.
2. **What fills the context window:** provider system prompt → AGENTS.md / CLAUDE.md → skill names + descriptions → tool definitions → codebase → conversation. Sessions start around 20k tokens, compaction happens near the limit.
3. **AGENTS.md / CLAUDE.md: "95% of people don't need them."** They load on every turn. Don't tell the model things it can see or already knows ("we use React", "use $ for money"). Keep them only for proprietary facts that every turn needs.
4. **Skills load in stages (progressive disclosure).** Only the name and description sit in context until the skill is needed. His example: a 944-token skill costs 53 tokens until it's used.
5. **Don't write a skill before you've done the workflow.** First walk the agent through it step by step, correcting it until you get a successful run. Then say "review what you did and create the skill". The skill gets written from real context.
6. **Don't install other people's skills.** Read them for ideas. Two reasons: the skill lacks *your* successful-run context, and downloaded skills are a security risk.
7. **Improve skills recursively:** it fails → ask it why → it fixes the problem → "update the skill so this doesn't happen again". His 8-source report skill took 5 loops and now runs reliably.
8. **Scale for productivity, not for what looks cool.** Start with one agent and its skills. Add a sub-agent only once a domain has proven workflows. Don't start with 15 sub-agents and 30 skills (he names Paperclip as the flashy example).
9. **Keep context use between fresh and about 70%.** Output gets worse as the window fills.
10. **"Templates are going to have a renaissance."** Code itself is now context. A solid web or mobile starter template guides the agent better than a long AGENTS.md.

## What it means for the template

- Claim 10 supports the whole project idea: a well-structured codebase *is* the agent's onboarding.
- **Keep CLAUDE.md / AGENTS.md small.** Only non-obvious rules: definition of done, commands, things that can't be seen in the code. No list of the stack.
- **Ship a skill-making workflow, not a pile of pre-made skills.** For example, a `/capture-skill` command ("review this session's successful run → write SKILL.md") and an "update skill from this failure" command. This follows claims 5–7.
- **Limit to a small set of example skills**, each with a precise `description`, since that is the only part always in context.
- **Grow agents in stages:** document a path from 1 main agent → add sub-agents per domain once workflows are proven. Don't ship a 20-agent roster by default.
- **Add a context-hygiene guide:** when to /compact or /clear, using sub-agents to keep file dumps out of the main context, 70% rule of thumb.
- **Security note** on third-party skills, MCP servers and agents.

## Where I'd push back or add nuance

- "CLAUDE.md costs N tokens every turn": it does take up window space, but prompt caching makes the repeated cost much lower than he suggests. The real reason to keep it short is attention and space, not money.
- "Agent files are a farce" goes too far for teams and open-source. A short file with commands, definition of done and conventions that aren't in the code is useful, especially across Claude Code, Codex, Cursor and others (AGENTS.md is the cross-tool standard).
- He doesn't cover hooks, permissions/settings, MCP, worktrees or parallel agents. These are core to "managing dev environments" and need other sources.
- Model names in the video (Opus 4.6, GPT 5.4) are from April 2026 and already out of date.

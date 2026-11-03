# Source 02 — "I built Claude Code. Use Subagents." (HACKS)

- **Video:** https://www.youtube.com/shorts/Nn0OyCWer1k
- **Who:** Charlie Automates. 1:51 Short, published 2026-02-02. The title quotes advice credited to Boris Cherny, creator of Claude Code; the speaker isn't him.
- **Collected:** 2026-11-03 from the transcript (auto captions)

## Claims made in the video

1. **Use sub-agents on purpose, not only when Claude decides to.** Doing side tasks in the main session wastes its context. Hand them to sub-agents and feed only the results back.
2. **Two ways to spawn them:**
   - **Parallel:** one session sends out several agents at once and collects all results together. Use it for independent tasks.
   - **Sequential:** agent 1 returns data, agent 2 builds on it, and so on. Use it when each step depends on the last.
3. **Write your sub-agent strategy into CLAUDE.md.** His says when to propose parallel vs sequential. For complex requests, Claude asks him whether to open several sub-agents.
4. "You're leaving 99% of its power on the table" is hype, not a measured claim.

## From the screenshots (9 frames, kept locally in ~/Desktop/subagents, not in this repo)

**How it works:**
- Main session (the orchestrator) → Task tool → each sub-agent starts with a fresh context, its own tools and no memory of the conversation or of other agents.
- Each sub-agent sends back **one message** plus an agent ID (so it can be resumed), then ends.
- The main session combines the results into the answer.

**Built-in sub-agent types, as shown in the video (Claude Code 2.1.29):**

| Type | Tools | Good for |
| --- | --- | --- |
| Explore | Glob, Grep, Read, WebFetch, WebSearch | finding code, quick lookups |
| Plan | same, read-only | architecture, design plans, trade-offs |
| Bash | Bash only | git, npm/yarn, docker, shell tasks |
| general-purpose | all tools | complex multi-step research + execution |
| claude-code-guide | read + web | questions about Claude Code / SDK / API |

The video shows general-purpose as "all tools except Edit/Write". In current Claude Code it can edit, so check `/agents` for the current list. Context size depends on the model, so "200k" isn't fixed.

**Parallel vs sequential examples:**
- **Parallel:** "find auth handlers" + "find error boundaries" + "check git history" all run at once. Faster.
- **Sequential:** "find the main config file" → "read config/app.ts, find DB connection" → "analyse the DB schema for those connection details". Slower but necessary.

**His CLAUDE.md section, "Ask About Subagent Execution for Complex Tasks":** for any multi-step task, file search or parallel work, Claude asks "How would you like me to execute it?" and offers three options:
- **Sequential sub-agents:** safer, easier to follow.
- **Parallel sub-agents:** faster, for independent subtasks.
- **Direct execution:** simpler tasks, full context visibility.

The section also lists when to suggest each option, and why: fresh context, no degradation, the user stays in control, no context pollution. It ends with an ASCII "execution strategy" diagram.

**Boris Cherny's tip #8, "Use subagents"** (X post, Jan 31):
- a. Add "use subagents" to a request when you want Claude to throw more compute at it, e.g. "use 5 subagents to explore the codebase".
- b. Offload individual tasks to keep the main context clean.
- c. Route permission requests to Opus via a hook (the rest is cut off in the screenshot).

## How it fits with source 01

- **They agree:** keep the main context clean, and sub-agents are how you do it.
- **They seem to clash on CLAUDE.md**, since 01 says keep it minimal. But a few lines on *when to delegate* are exactly the kind of non-obvious working rule 01 says a CLAUDE.md is for. A short "Sub-agents" section passes both tests.
- **01's "scale slowly" is about permanent custom agents**, like a marketing agent. 02 is about throwaway sub-agents for single tasks, like search, summarise or review. Use the throwaway kind freely, and add permanent ones slowly.

## What it means for the template

Add to `config/claude/CLAUDE.md` (about 6 lines):

- Delegate anything that reads a lot to get a little: broad code search, long docs or transcripts, logs, reviews. The main session keeps only the conclusion.
- Independent tasks → parallel sub-agents in one message. Dependent steps → sequential, each one getting the previous result.
- For big or multi-part requests, propose the split (parallel or sequential) before starting.
  Ask only for big requests, not on every multi-step task as in his version. Asking every time adds a question to nearly every request.
- Small jobs (a handful of tool calls) → do them directly; a sub-agent costs more than it saves.

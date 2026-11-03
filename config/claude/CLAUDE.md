# Global rules

Keep this file short. It loads on every turn, so only put here what the agent
cannot see in the code. Project details belong in each repo's own AGENTS.md or CLAUDE.md.

## Definition of done
- Run the project's "Verified commands" (in its AGENTS.md) before saying work is finished.
  If there are none, find the lint/test/build commands, run them, and propose adding them.
- Verify the change in the running app, not just that it compiles.

## Git
- Never commit unless asked. Branch first; never commit to main.
- Never push. The user pushes. (The claude-guard hook blocks git push.)
- One agent per worktree. Never edit a checkout another agent is working in.
- Sub-agents never commit. They leave changes uncommitted and report what changed;
  the session that started them reviews the diff.
- Every commit, in any worktree, comes after the user has seen the diff. Never auto-merge.

## Sub-agents
- Delegate work that reads a lot to return a little: code search, long docs, logs, reviews.
  Keep only the conclusion in the main session.
- Independent tasks: parallel sub-agents in one message. Dependent steps: sequential,
  each one given the previous result.
- For big multi-part requests, propose the plan first: sequential, parallel, or direct.
- Small jobs (a few tool calls): do them directly.

## Skills
- Write a skill only after the workflow has run successfully once in this session.
- When a skill fails and the failure gets fixed, propose a skill update so it doesn't happen again.
- Skills with side effects (deploy, release, rollback, sending anything) get
  `disable-model-invocation: true`, so they only run when the user types them.

## Agent docs (CLAUDE.md, AGENTS.md, skills)
- Propose changes to them; never edit them silently.
- No lines that go stale: no dates, "now"/"currently", version numbers or ticket IDs.

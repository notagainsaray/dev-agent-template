# Global rules

Keep this file short. It loads on every turn, so only put here what the agent
cannot see in the code. Project details belong in each repo's own AGENTS.md or CLAUDE.md.

## Definition of done
- Run the project's own checks (lint, tests, build) before saying work is finished.
- Verify the change in the running app, not just that it compiles.

## Git
- Never commit unless asked. Branch first; never commit to main.
- Never push. The user pushes. (The claude-guard hook blocks git push.)
- One agent per worktree. Never edit a checkout another agent is working in.
- Parallel work comes back through review (a PR or a read diff), never an automatic merge.

## Sub-agents
- Delegate work that reads a lot to return a little: code search, long docs, logs, reviews.
  Keep only the conclusion in the main session.
- Independent tasks: parallel sub-agents in one message. Dependent steps: sequential,
  each one given the previous result.
- For big multi-part requests, propose the plan first: sequential, parallel, or direct.
- Small jobs (a few tool calls): do them directly.

## Skills
- Write a skill only after the workflow has run successfully once in this session.
- When a skill fails and the failure gets fixed, update the skill so it doesn't happen again.
- Skills with side effects (deploy, release, rollback, sending anything) get
  `disable-model-invocation: true`, so they only run when the user types them.

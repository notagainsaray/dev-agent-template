# Global rules

Keep this file short. It loads on every turn, so only put here what the agent
cannot see in the code. Project details belong in each repo's own AGENTS.md or CLAUDE.md.

## Definition of done
- Run the project's own checks (lint, tests, build) before saying work is finished.
- Verify the change in the running app, not just that it compiles.

## Git
- Never commit or push unless asked. Branch first; never commit to main.
- One agent per worktree. Never edit a checkout another agent is working in.

## Skills
- Write a skill only after the workflow has run successfully once in this session.
- When a skill fails and the failure gets fixed, update the skill so it doesn't happen again.

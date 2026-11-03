# RFC-0000: <title>

<!--
Copy to docs/rfc/NNNN-short-name.md. An RFC says HOW to build what a PRD asks for.
Claims about the current system name their source (file path, ticket, metric).
The implementation plan is written so each task can go to one agent in one worktree.
-->

| | |
| --- | --- |
| Status | Draft · In review · Accepted · Implemented · Rejected |
| Author | |
| Reviewers | |
| Date | YYYY-MM-DD |
| PRD | PRD- |

## Context
<!-- What exists today and why it isn't enough. Link the code. -->

## Proposal
<!-- The design: data model, APIs, components, flows. Diagrams welcome. -->

## Alternatives considered
| Option | Why not |
| --- | --- |
| Do nothing | |

## Risks
<!-- Security, privacy, performance, migration, cost. How each one is reduced. -->

## Rollout
<!-- Feature flag, migration order, how to roll back, who is told. -->

## Implementation plan

Each task is small enough for one agent, names its acceptance check, and lists what it
waits on. Tasks with nothing to wait on can run in parallel.

| # | Task | Done when | Depends on | Linear |
| --- | --- | --- | --- | --- |
| 1 | | | — | |
| 2 | | | 1 | |

Start a task as a background agent:

```sh
wt <issue-id> --bg "Implement task 1 of docs/rfc/0000-short-name.md. Read the RFC first."
```

## Open questions
- [ ] 

# AGENTS.md

<!--
Project instructions for coding agents. Copy this file to your repo root.
Claude Code reads CLAUDE.md, so also create a CLAUDE.md containing one line: @AGENTS.md

Keep it short. It loads on every turn, so only write what the agent cannot see in the code.
Don't describe the stack. Don't add dates, "currently", version numbers or ticket IDs.
-->

## Verified commands

The definition of done. Every command here was run on a clean checkout and works.
Change one only after you've run the new version.

| Purpose | Command |
| --- | --- |
| Install | `npm install` |
| Lint | `npm run lint` |
| Test | `npm test` |
| Build / type-check | `npm run build` |
| Run the app | `npm run dev` |

## Docs

PRDs in `docs/prd/`, RFCs in `docs/rfc/`, ADRs in `docs/adr/`, numbered `NNNN-short-name.md`.

## Rules the code doesn't show

- <!-- e.g. "Never edit files in generated/; run `npm run codegen` instead." -->

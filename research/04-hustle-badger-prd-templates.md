# 04: Hustle Badger, "PRD template examples"

Source: https://www.hustlebadger.com/what-do-product-teams-do/prd-template-examples/
(also shared as a LinkedIn post by Ed Biden, "Nobody reads your PRD…"). Read 2026-11-03.

## The argument
A PRD is a communication tool, so there is no single right format. Pick the template
for **who reads it and what they need from it**. That answer sets the sections, the
length, and whether the document is fixed or keeps changing.

> "With every section you add, the PRD gets longer and people are less likely to read it."

## Templates compared (12, plus a reviewer agent)

| Source | What stands out |
| --- | --- |
| Figma (via Coda) | Launch planning, long checklist |
| Lenny Rachitsky | Very simple; asks who the target audience is |
| Linear (Nan Yu) | Three sections only: **Context, Usage scenarios, Milestones**. Sections change at different speeds: context hardly ever, milestones often |
| Kevin Yien (Square) | Heavily annotated, operational checklist |
| Asana | "Spec": problem statements, hypotheses, **non-goals**, narrative vision |
| Intercom | "Intermission": one A4 page. "Do not add the solution here." Plain words, no codenames |
| Product Hunt | Very complete (go-to-market, architecture, mockups); warns about bloat |
| Adam Waxman (SeatGeek) | **Decision journal**: options explored vs. chosen |
| Steve Morin (Asana) | About five pages, centred on risks, mitigations and open questions |
| Adam Thomas | Five sections; one page where possible; a living document used in meetings |
| Amazon | PR/FAQ "working backwards": a press release plus FAQs instead of a PRD |
| Hustle Badger | Filled in one step at a time through development; ends with **impact** |
| Hustle Badger PRD Reviewer | A Claude Code agent with several personas (engineering lead to CEO) that critiques a PRD |

## On AI
- Draft with Claude Code: pull in context, ask questions (AskUserQuestion), use your own template.
- Review with several personas to "red team your initial idea from every possible angle"
  before anyone else sees it.

## What we took
- **PRD format** (`templates/docs/PRD.md`):
  - aims for one page;
  - core sections are Linear's three (Context, Usage scenarios, Milestones) plus goals and non-goals, metrics and open questions;
  - everything else is optional;
  - metrics get an Actual column;
  - there's a decision log that links to ADRs, and an Impact section to fill in after launch.
- **For the `/prd` skill**, once the first real run works:
  - ask who reads the PRD and what they need to decide, then pick short, full or PR/FAQ;
  - review in parallel from several personas, each sub-agent seeing only the document;
  - offer to update the PRD as the work moves.
- **Not taken:** their reviewer agent. We build our own from a real run rather than install one unread (decision 2).

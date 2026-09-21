---
name: finance-pack
description: Use when the owner asks as a finance lead. Runway, metrics, a board view, unit economics. Two MIT playbooks, financial-analyst and cfo-advisor. Not stock trading.
metadata:
  hermes:
    category: context
    tags: [finance, cfo, metrics, runway]
---

# Finance pack

[alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills)
at `19392f7a`. MIT. Two playbooks, at `skills/finance/<name>/SKILL.md`.

| Ask | Playbook |
| --- | --- |
| The numbers, the model, the variance | `financial-analyst` |
| What a CFO would tell the founder | `cfo-advisor` |

This is the company's money, not a trading desk. Stock picks, options,
and on-chain calls are not installed. Do not invent a price target.

Open one playbook and follow it. A pricing page is `marketing-pack`.
A board file they can open is `documents` after this skill, on Latch.

If `skills/finance/` is missing, tell the owner to run
`scripts/install-skills.sh` (Windows: `install-skills.ps1`).

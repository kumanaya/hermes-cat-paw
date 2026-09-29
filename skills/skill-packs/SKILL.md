---
name: skill-packs
description: Use first for authorized work requests. Routes to the existing packs and the local adapted delivery, minimal-code, token-efficiency, communication, graph, knowledge, recent-research, catalog, scientific, and diagram packs.
metadata:
  category: context
  tags: [skills, engineering, product, marketing, design, research, documents, software-delivery, minimal-code, token-efficiency, communication, code-graph, knowledge, catalog, scientific, diagrams]
---

# Skill packs

Cybersecurity is one pack. Read the matching router, then open **one**
playbook and follow it. Do not invent the procedure from memory, and do
not flatten a pack into one guess. For the local adapted packs below, the
same rule is strict: choose exactly one child playbook per turn, never two.

Precedence is deterministic. Apply these rules in order:

1. Classify cybersecurity and change-review first. Authorized recon, a hunt,
   or a security report selects `cybersecurity-pack`; a pull request, patch,
   or snippet selects `change-review` after `target-workspace`. Neither
   classification falls through to a broad engineering, product, or marketing
   row. If both a live security probe and a patch are requested, handle them
   as separate turns; each turn still opens only one playbook.
2. An exact named child outcome beats broad category rows. For an agent skill,
   provenance/source/license review wins over generic skill pressure-testing: use
   `agent-skill-provenance-license-review`, not
   `skill-definition-pressure-test`, when the question is source, provenance,
   or license. Architecture decision planning wins over generic engineering architecture:
   use `software-architecture-decision-gate`. Feature-need validation wins over generic product ideation:
   use `feature-necessity-decision`. A bounded 30-day public/community signal wins over generic competitor/research:
   use `thirty-day-cross-source-signal-brief` or
   `community-claim-sentiment-pulse`.
3. If no first-priority classification or exact child outcome matches, use
   the narrowest broad category row below.

After the router selects a pack, open exactly one child playbook for the turn.
Do not combine children or use a router as a second playbook.

| Ask | Read | Playbooks land at |
| --- | --- | --- |
| Bug, spec, review, tickets, TDD, CI, QA | `engineering-pack` | `skills/engineering/` |
| PRD, discovery, roadmap, GTM, prioritization | `product-pack` | `skills/product/` |
| Copy, SEO, launch, ads, social, community, content | `marketing-pack` | `skills/marketing/` and `skills/content/` |
| Cold email, prospecting, a demo, a POC | `sales-pack` | `skills/marketing/` and `skills/sales/` |
| Renewal, health, QBR, churn, expansion | `customer-success-pack` | `skills/customer-success/` |
| Runway, metrics, a CFO view | `finance-pack` | `skills/finance/` |
| Motion, UI, accessibility, a screen that should not look generic | `design-pack` | `skills/design/` |
| A PDF, docx, pptx, or xlsx the owner can open | `documents` | written on Latch |
| A paper, a literature review, a citation check | `academic-research-pack` | `skills/academic-research/` |
| Architecture decision planning, investigation DAG, generic skill pressure test | `software-delivery-pack` | `skills/software-delivery-pack/` |
| Feature-need validation, abstraction removal, shortcut debt | `minimal-code-pack` | `skills/minimal-code-pack/` |
| Model call inventory, instruction compression, context migration | `token-efficient-agenting-pack` | `skills/token-efficient-agenting-pack/` |
| Action-first reset, low-load runbook, incident update | `action-first-communication-pack` | `skills/action-first-communication-pack/` |
| Repository graph, change blast radius, cross-layer trace | `code-graph-pack` | `skills/code-graph-pack/` |
| Onboarding tour, domain map, evidence-linked question map | `codebase-knowledge-pack` | `skills/codebase-knowledge-pack/` |
| Bounded 30-day public/community signal, competitor momentum, community pulse | `recent-research-pack` | `skills/recent-research-pack/` |
| Agent-skill discovery, minimal stack, provenance/source/license review | `agent-skill-catalog-pack` | `skills/agent-skill-catalog-pack/` |
| Study power, reproducible compute, claim calibration | `scientific-research-pack` | `skills/scientific-research-pack/` |
| Trust-boundary, lifecycle, release/rollback diagram | `diagram-design-pack` | `skills/diagram-design-pack/` |
| Authorized recon, a hunt, or a security report | `cybersecurity-pack` | `skills/cybersecurity-skills/` |
| A pull request, patch, or snippet | `change-review` | after `target-workspace` |

If a local adapted pack or router is missing, tell the owner to run
`scripts/install-skill-packs.sh --routers-only` (Windows:
`install-skill-packs.ps1 -RoutersOnly`). If an external pack is missing, run
`scripts/install-skill-packs.sh` (Windows: `install-skill-packs.ps1`). If the
cybersecurity pack is missing, run `scripts/install-skills.sh` (Windows:
`install-skills.ps1`). Do not substitute a cloud workspace for a Latch checkout.

Files the owner keeps go through Latch, under
`~/CatPaw/workspaces/<slug>/` on their computer. Not `/var/lib/hermes`.
Not `~/Plow`, unless they asked for the Latch inbox.

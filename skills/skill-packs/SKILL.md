---
name: skill-packs
description: Use first when the ask is not only authorized cybersecurity. Routes to engineering, product, marketing, sales, customer success, finance, design, documents, or academic research.
metadata:
  hermes:
    category: context
    tags: [skills, engineering, product, marketing, design, research, documents]
---

# Skill packs

Cybersecurity is one pack. Read the matching router, then open **one**
playbook and follow it. Do not invent the procedure from memory, and do
not flatten a pack into one guess.

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
| Authorized recon, a hunt, or a security report | `cybersecurity-pack` | `skills/cybersecurity-skills/` |
| A pull request, patch, or snippet | `change-review` | after `target-workspace` |

If the playbook tree is missing, tell the owner to run
`scripts/install-skills.sh` (Windows: `install-skills.ps1`). Do not
substitute a cloud workspace for a Latch checkout.

Files the owner keeps go through Latch, under
`~/CatPaw/workspaces/<slug>/` on their computer. Not `/var/lib/hermes`.
Not `~/Plow`, unless they asked for the Latch inbox.

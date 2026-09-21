---
name: customer-success-pack
description: Use for customer success. Health, onboarding, renewal, expansion, QBR, churn, handoff, and the hard conversation. The CSPulse library, MIT.
metadata:
  hermes:
    category: context
    tags: [customer-success, renewal, churn, qbr, onboarding]
---

# Customer success

[CSPulse/customer-success-skills](https://github.com/CSPulse/customer-success-skills)
at `0e872773`. MIT. Playbooks at `skills/customer-success/<name>/SKILL.md`.

Open the one that matches the motion. Do not tour the library.

| Ask | Playbook |
| --- | --- |
| What is true about this account | `account-context`, `health-read`, `account-research` |
| The plan for a new account | `onboarding-plan`, then `account-plan` |
| A call | `call-prep`, then `call-recap` |
| The room with an executive | `exec-conversation`, `business-review` |
| Renewal | `renewal-risk`, `renewal-forecast`, `renewal-negotiation` |
| They might leave | `churn-postmortem` after the fact. Before it, `renewal-risk` |
| Grow the account | `expansion-case` |
| Hand the account to someone else | `handoff` |
| Say the difficult thing | `hard-conversation` |
| Who matters | `stakeholder-map` |
| This week | `weekly-plan` |

`onboarding-plan` here is the customer's first months. The marketing
`onboarding` playbook is the product's first screen. Do not swap them.

A cold first touch is `sales-pack`. Do not email the customer until the
owner says the note may go out.

If `skills/customer-success/` is missing, tell the owner to run
`scripts/install-skills.sh` (Windows: `install-skills.ps1`).

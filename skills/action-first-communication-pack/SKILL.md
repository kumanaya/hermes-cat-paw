---
name: action-first-communication-pack
description: "Routes opt-in action-first updates, low-load runbooks, and stalled-task resets to one Cat Paw communication playbook per turn."
metadata:
  hermes:
    category: context
    tags: [communication, action-first, opt-in, runbooks, incident, cat-paw]
---

# Action-first communication pack

This is a local Cat Paw adaptation of ideas from [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd), audited at the exact commit `839872f9d1cd634fed642b4589ce7226199cc15f`. The source repository is MIT licensed. The license caveat is that this pack uses original Cat Paw prose and a deliberately renamed operating set, not copied source text. The name is descriptive of a communication style, not a medical claim. It is a local adaptation, not a clinical or diagnostic resource.

Read this router, then open exactly one child playbook. The style is opt-in: do not impose it on the owner or another participant, and do not use it to make a person disclose health information. Keep the full internal analysis, evidence, uncertainty, and reasoning needed for a safe decision; shorten the presentation, not the record.

| Request | One child playbook |
| --- | --- |
| A task is stuck and needs one concrete next move | `stalled-task-next-action-reset` |
| A repeatable task needs a low-cognitive-load runbook | `low-cognitive-load-runbook` |
| An incident needs a concise status update | `one-screen-incident-status-update` |

## Expansion and device boundary

These playbooks may compress ordinary updates, but they must expand for security-sensitive work, ambiguity, destructive actions, data loss, accessibility or legal consequences, and any irreversible step. Show the full reasoning, alternatives, risks, approvals, and evidence needed for those cases.

A computer, browser, repository, or durable file requires `target-workspace` and `plow-latch`, an owner request, and the appropriate permission. Keep private evidence in `~/CatPaw/workspaces/<slug>/` on the owner's computer, not in the Hermes container. No communication playbook sends a message, commits, pushes, merges, installs, or mutates an external system without a separate explicit approval.

---
name: one-screen-incident-status-update
description: "Produces an opt-in concise incident update that separates facts, impact, unknowns, and the next owned action."
metadata:
  hermes:
    category: context
    tags: [incident, status, communication, evidence, escalation]
---

# One-screen incident status update

## When to use

Use this playbook when the owner asks for a compact incident update for a phone thread, stand-up, or handoff. It is an opt-in presentation format, not a diagnosis or a way to suppress the incident record. Use a fuller report for security incidents, ambiguous impact, destructive actions, data loss, accessibility harm, or legal or regulatory consequences.

## Required inputs

- Incident name, time window, current state, and audience.
- Confirmed impact and affected people or systems.
- Evidence and source timestamps, including what is still being checked.
- Mitigation, owner, next action, deadline, and escalation threshold.
- Redaction rules and the owner's desired level of detail.

## Procedure

1. State the current state using a bounded label such as investigating, mitigating, monitoring, resolved, or blocked. Do not use a confident label without evidence.
2. Write one line of confirmed impact and one line of current user or business effect. Keep unverified impact explicitly marked.
3. Summarize what is known, what is being checked, and what remains unknown. Retain links or paths to the full evidence rather than copying sensitive details.
4. Name the single next action, its owner, and the time by which the next update will occur.
5. Add the escalation trigger and the reason the format is sufficient or insufficient. Expand the update for security, ambiguity, destructive actions, data loss, or accessibility risk.
6. Review for private data, credentials, speculation, blame, and unsupported recovery claims. Redact before delivery.
7. Deliver the update and retain the complete internal analysis, raw evidence, decisions, and follow-up in the incident record.

## Output and evidence

Provide the one-screen update plus a compact evidence pointer, timestamp, author or owner, state label, and next-update time. Store private incident records in the target workspace on Latch. The update must not claim a probe, recovery, or user impact that was not observed.

## Guardrails

- Do not diagnose, speculate about people, or turn a status update into a performance assessment.
- Do not omit security analysis, uncertainty, destructive-action approvals, or material accessibility impact.
- Do not send or publish the update without the owner's explicit approval.
- Do not expose secrets, personal data, raw tokens, or private paths unnecessarily.
- Use `target-workspace` and `plow-latch` for device evidence; the Hermes container is not the incident workspace.

## Done condition

The recipient can identify the current state, verified impact, unknowns, owner, next action, and escalation threshold, while the full record remains available. The update is approved for its stated audience and contains no unsupported claim.

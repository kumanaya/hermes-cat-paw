---
name: low-cognitive-load-runbook
description: "Builds an opt-in, short runbook that makes a repeatable task executable while preserving its full safety analysis."
metadata:
  hermes:
    category: context
    tags: [runbook, checklist, cognitive-load, opt-in, procedures]
---

# Low cognitive load runbook

## When to use

Use this playbook when a repeatable task has too many implied steps, handoffs, or reminders. The owner may opt into a compact runbook for routine work. It is not a diagnosis, a productivity promise, or permission to remove necessary detail.

## Required inputs

- The task outcome, audience, trigger, and completion definition.
- The current sequence, available tools, inputs, and handoffs.
- Known failure modes, approvals, security boundaries, and data-loss risks.
- The desired format, reading audience, and how much detail the owner wants hidden from the first view.
- A safe way to test or dry-run the runbook.

## Procedure

1. State the outcome and the smallest safe starting state. Do not hide prerequisites in a slogan.
2. Break the work into observable steps with one action per step, an owner, and an expected result.
3. Put approvals, stop conditions, validation, accessibility checks, and rollback at the point where they matter. Expand the text for destructive, ambiguous, security-sensitive, or irreversible work.
4. Remove repetition and nonessential jargon while retaining full internal analysis, rationale, alternatives, and evidence links.
5. Add a short failure path, a recovery path, and a place to record unknown or unavailable information.
6. Tabletop the runbook with a representative case. If execution is requested, use only owner-approved tools through Latch and a target workspace.
7. Deliver the runbook with a version, owner, review date, and a clear done condition.

## Output and evidence

Return the compact runbook, expanded safety notes, step evidence, test cases, and review schedule. Keep private instructions, logs, and recovery artifacts in `~/CatPaw/workspaces/<slug>/` on Latch. Do not expose credentials or personal data in a runbook.

## Guardrails

- Do not diagnose or make health or cognitive claims.
- Do not compress away security, ambiguity, accessibility, validation, data-loss prevention, approval, or rollback details.
- Do not send messages, install packages, commit, push, merge, or mutate a device without explicit approval.
- Do not claim the runbook is tested if only the wording was reviewed.
- Read `target-workspace` and `plow-latch` before any private or device action.

## Done condition

The owner can identify the trigger, steps, approvals, failure handling, and completion evidence, while the full analysis and safety notes remain available. The runbook is marked tested, tabletop-only, or unavailable, with no ambiguity about its status.

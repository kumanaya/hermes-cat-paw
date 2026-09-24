---
name: stalled-task-next-action-reset
description: "Converts a stalled task into one owned, executable next action without hiding analysis or inventing progress."
metadata:
  hermes:
    category: context
    tags: [stalled-task, next-action, reset, ownership, communication]
---

# Stalled task next-action reset

## When to use

Use this playbook when work has lost momentum, the next step is unclear, or several people are waiting on an unstated action. It is a reset of ownership and sequence, not a performance judgment and not a diagnosis. It can be used only when the owner opts into this style.

## Required inputs

- The original outcome and the current stopping point.
- What is known, unknown, blocked, or waiting on another person.
- The smallest safe next action, its owner, deadline, and permission boundary.
- Evidence already collected and any security, data-loss, accessibility, or destructive risk.
- The channel and level of detail the recipient wants.

## Procedure

1. Restate the outcome and the exact point where progress stopped. Separate a missing decision from missing work.
2. Ask what would count as a useful next action, not what would prove the whole task complete.
3. Select one action that is small, observable, and reversible where possible. Name its owner, input, deadline, and expected artifact.
4. Check the action against permissions, security, ambiguity, data loss, and destructive-action rules. Expand the explanation or request approval when risk is present.
5. State the action in a short update while retaining the complete internal analysis, evidence, alternatives, and unresolved questions.
6. Record what will be checked next and what would cause a stop. Do not silently change files, send messages, commit, push, or merge.
7. Close the reset only when the action is accepted, refused with a reason, or marked blocked with an owner and next checkpoint.

## Output and evidence

Return the outcome, blocker, one next action, owner, deadline, evidence reviewed, risk expansion, and stop condition. For a device or repository action, record the operation status and durable path without secrets. Label progress as observed, planned, or unavailable.

## Guardrails

- Do not diagnose, label, or infer a medical or cognitive condition.
- Do not shorten away internal analysis, security reasoning, uncertainty, or alternatives.
- Expand detail for security, ambiguity, destructive actions, data loss, accessibility, and legal consequences.
- Do not send, install, commit, push, merge, or mutate a system without a separate explicit approval.
- Use `target-workspace` and `plow-latch` before private or device work; do not use the container as a workspace.

## Done condition

There is one accepted, declined, or blocked next action with a named owner and checkpoint, and the full analysis remains available. No progress is claimed beyond the evidence actually received.

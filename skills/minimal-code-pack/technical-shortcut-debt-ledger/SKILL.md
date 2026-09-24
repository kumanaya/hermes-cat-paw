---
name: technical-shortcut-debt-ledger
description: "Turns a deliberate engineering shortcut into owned, time-bounded debt with compensating controls, verification, and rollback."
metadata:
  hermes:
    category: context
    tags: [technical-debt, shortcuts, risk, controls, review, rollback]
---

# Technical shortcut debt ledger

## When to use

Use this playbook when a team knowingly takes a faster path than the preferred design: a temporary schema, skipped migration, hard-coded value, manual step, reduced validation, or a temporary compatibility shim. It is not a place to hide an unreviewed failure or a permanent workaround.

## Required inputs

- The shortcut, the normal path it replaces, and the reason it is being considered.
- The affected code, data, users, environments, and security or accessibility boundary.
- A named owner, decision date, review or expiry date, and a rollback trigger.
- Available tests, monitoring, validation, data backup, and recovery evidence.
- The exact next cleanup action and the person authorized to make it.

## Procedure

1. Describe the shortcut in plain language and identify which guarantees it gives up. Do not call a risk a simplification if it changes correctness, security, validation, or data protection.
2. Classify impact and likelihood. Include data loss, privacy, accessibility, operational, compatibility, and user-trust effects.
3. Define compensating controls that are observable and proportionate. State what will not be protected if a control is missing.
4. Set an expiry or review date, an accountable owner, a trigger for early rollback, and a cleanup ticket or task without pretending the ticket is complete.
5. Test the normal, failure, recovery, and rollback paths as far as the approved environment allows. Record commands, revisions, and results.
6. Write the ledger entry with the reason, scope, controls, evidence, residual risk, and exact next action. Review it at the stated time.
7. Close the entry only after the replacement is verified and the old path is safely retired; otherwise keep it open and visible.

## Output and evidence

Return a ledger entry with owner, dates, risk class, controls, evidence links, review state, rollback trigger, and cleanup status. Private code, logs, and recovery records go to the target workspace on Latch. Label observed, inferred, and unavailable checks.

## Guardrails

- Do not conceal missing tests, failed validation, or an expired review behind a green build.
- Do not use a shortcut to bypass authentication, authorization, accessibility, privacy, data-loss prevention, or rollback.
- Do not install, commit, push, merge, deploy, or mutate cloud/lab resources while recording debt.
- Do not claim recovery without a real restore or rollback check.
- Read `target-workspace` and `plow-latch` before private or device work; never use the Hermes container as evidence storage.

## Done condition

The ledger has an owner, expiry, controls, evidence, residual risk, and rollback trigger, and its state is accurate. Cleanup is complete only when the replacement and rollback have been verified; otherwise the item remains open with a clear next action.

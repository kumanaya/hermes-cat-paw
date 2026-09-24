---
name: minimal-agent-skill-stack-selection
description: "Chooses the smallest sufficient skill stack for a task, with overlap, dependency, provenance, and rollback checks."
metadata:
  hermes:
    category: context
    tags: [skill-selection, minimal-stack, dependencies, provenance, rollback]
---

# Minimal agent skill stack selection

## When to use

Use this playbook after discovery has produced candidates and the owner wants the least complicated set of skills that can do the job. It is a selection decision, not an installation plan.

## Required inputs

- The task outcome, acceptance criteria, deadline, and risk class.
- Candidate skills with source, exact revision, license, and scope metadata.
- Existing Cat Paw packs and tools that may already cover the task.
- Data sensitivity, permission boundaries, dependencies, and rollback expectations.
- The owner authorized to select or reject a stack.

## Procedure

1. Restate the outcome and list the capabilities it actually requires. Separate a capability from a convenient implementation.
2. Check existing Cat Paw packs first. Reuse an authoritative pack when it covers the request; do not stack near-duplicates.
3. Score candidates by task fit, safety boundary, dependency burden, maintenance cost, evidence needs, and license clarity. Mark unknown values unavailable.
4. Try the smallest stack: one skill where possible, then the minimum additional skill only for a distinct requirement. Do not select an installer, framework, or catalog bundle as a shortcut.
5. Define conflicts, precedence, data exposure, and a rollback for the selected stack. Confirm that one playbook remains authoritative for the turn.
6. Record why rejected candidates were not selected and what evidence would change the decision.
7. Deliver the selected stack and provenance checklist; stop before installation or execution.

## Output and evidence

Return the selected item or items, source and exact revision, license and scope caveat, capability mapping, dependency and data risks, overlap decisions, and rollback. Use measured, inferred, and unavailable labels for any fit or efficiency claim. Keep private notes in the target workspace through Latch.

## Guardrails

- No full catalog or AAS Core installation, bulk import, auto-update, or package execution.
- Do not make a legal conclusion; preserve the source's license notice and uncertainty.
- Do not add a skill that conflicts with a Cat Paw boundary or exposes private data.
- Do not install, commit, push, merge, or deploy during selection.
- Use `target-workspace` and `plow-latch` for private artifacts; the Hermes container is not a target workspace.

## Done condition

The owner has a minimal, provenance-recorded stack or a no-skill decision, with one authoritative playbook, explicit risks, and a rollback. Nothing was installed or executed as an implicit part of choosing.

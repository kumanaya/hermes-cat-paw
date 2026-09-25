---
name: reproducible-scientific-compute-plan
description: "Plans a reproducible scientific computation with data provenance, environment records, checkpoints, checks, and honest unavailable dependencies."
metadata:
  hermes:
    category: context
    tags: [reproducibility, computation, environment, provenance, validation]
---

# Reproducible scientific compute plan

## When to use

Use this playbook before running a scientific computation whose result another person may need to reproduce or audit. It is a plan for safe, reviewable execution, not permission to mutate a lab, cloud environment, or remote dataset.

## Required inputs

- The computation objective, inputs, expected outputs, and acceptance checks.
- Data provenance, sensitivity, licensing or consent constraints, and permitted storage location.
- Source revision, runtime language, dependencies, hardware or accelerator needs, and known nondeterminism.
- Available tools and credentials already supplied through an approved mechanism; do not ask for hidden secrets.
- Resource budget, timeout, restart policy, owner, and rollback or cleanup plan.

## Procedure

1. Define the computation contract: inputs, transformations, outputs, units, tolerances, and what would count as failure.
2. Inventory data and code provenance. Record checksums or immutable references when available, and redact sensitive values.
3. Record the runtime plan: language, package versions, hardware, seeds, environment files, and any unavailable dependency. Do not pretend a version is pinned if it is not.
4. Divide the run into restartable stages with intermediate checks, logs, and validation of units, shapes, ranges, and invariants.
5. Define isolation, storage, access, cleanup, and rollback. Keep credentials in the approved secret store; do not discover or print them.
6. Tabletop the plan and identify the smallest non-sensitive smoke test. Obtain owner approval before running code, using a lab, or changing a cloud resource.
7. Deliver the runbook, evidence checklist, expected artifacts, and stop conditions. Do not execute the study in this playbook.

## Output and evidence

Return the computation contract, provenance table, environment manifest, stage plan, validation checks, resource estimate, rollback, and unavailable-dependency list. Label each item measured, inferred, or unavailable. Store private code and logs in the target workspace through Latch.

## Guardrails

- Do not mutate a laboratory instrument, cloud account, remote dataset, or production service.
- Do not discover hidden credentials, expose secrets, or run untrusted package code.
- Do not invent a dependency version, checksum, runtime result, or successful validation.
- Do not require self-citation or use a result to make a clinical decision.
- Use `target-workspace` and `plow-latch`; keep the Hermes container free of private research data.

## Done condition

The computation has a versioned contract, provenance and environment record, restartable stages, validation and rollback plan, and an explicit unavailable list. No external mutation or unapproved execution occurred, and the owner knows what remains to authorize.

---
name: dependency-abstraction-removal-audit
description: "Audits whether a dependency, wrapper, or abstraction earns its maintenance cost and defines a safe removal or retention plan."
metadata:
  hermes:
    category: context
    tags: [dependencies, abstractions, compatibility, migration, rollback]
---

# Dependency abstraction removal audit

## When to use

Use this playbook before removing a package, wrapper, interface, adapter, generated layer, or convenience module. It applies when a team suspects that an abstraction is unnecessary, but the dependency may be carrying security, compatibility, validation, or migration behavior that is not obvious from its name.

## Required inputs

- The dependency or abstraction, its exact version or revision, and the owner.
- All known direct and indirect call sites, configuration, tests, and generated consumers.
- The behavior it promises, including error handling, validation, accessibility, security, and data handling.
- Alternatives to direct use and the compatibility or migration constraints.
- A rollback point, data-loss concern, and the person authorized to approve removal.

## Procedure

1. Freeze the audit boundary. Record the current revision, lockfile state, supported platforms, and what must remain compatible.
2. Map consumers with static evidence. Mark each edge observed, inferred, or unknown; include tests, documentation, build scripts, and operational tooling.
3. State the abstraction's contract and the risks of direct use. Check authentication, authorization, input validation, error behavior, accessibility semantics, privacy, and data migration.
4. Compare retention with removal using maintenance, security, performance, compatibility, and rollback criteria. Do not assume a smaller dependency tree is lower risk.
5. Design a staged migration: isolated change, compatibility tests, telemetry or observation that does not expose secrets, and a precise rollback trigger.
6. Run only owner-approved static checks first. Private repository tests or package installation require `target-workspace`, `plow-latch`, trust classification, and explicit execution approval for untrusted code.
7. Deliver a retain/remove/defer decision, evidence, migration plan, and rollback procedure. Do not perform the removal in this playbook.

## Output and evidence

Produce a dependency inventory, consumer map, contract and risk table, proposed migration, test evidence, and rollback checklist. Put paths, revisions, and raw non-secret output in `~/CatPaw/workspaces/<slug>/` on Latch. Mark unavailable checks clearly.

## Guardrails

- Do not remove a dependency, update a lockfile, install a replacement, commit, push, merge, or deploy automatically.
- Do not weaken security, correctness, accessibility, validation, or data-loss prevention to simplify a call path.
- Never execute fork or pasted code without a separate owner-approved Latch action.
- Do not print credentials, tokens, cookies, or private payloads; redact evidence.
- If a consumer or contract is unknown, defer removal rather than guessing.

## Done condition

The owner has an evidence-backed retain, remove, or defer decision, a staged migration and rollback plan, and a list of all skipped or unavailable checks. The dependency remains untouched until a separately authorized implementation task begins.

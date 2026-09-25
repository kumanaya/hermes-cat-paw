---
name: release-migration-rollback-sequence-diagram
description: "Creates an accessible release, migration, validation, and rollback sequence without executing or mutating a deployment."
metadata:
  hermes:
    category: context
    tags: [release, migration, rollback, sequence, svg, safety]
---

# Release migration rollback sequence diagram

## When to use

Use this playbook when the owner needs a visual order for a release, schema or data migration, validation, cutover, or rollback. It documents a plan; it does not run a release, touch a database, or claim that rollback is safe.

## Required inputs

- The release owner, system and environment, current and target versions, and exact diagram question.
- Migration steps, dependencies, compatibility windows, validation checks, and stop conditions.
- Data-loss, security, accessibility, privacy, and downtime constraints.
- Rollback authority, recovery point, and the point at which rollback is no longer possible.
- A target-workspace path and the preferred self-contained HTML/SVG format.

## Procedure

1. Confirm the owner request and separate the planned sequence from commands that would actually execute. Do not access production without explicit permission.
2. Define preconditions, actors, version or schema states, and invariants that must hold before cutover.
3. Lay out forward steps in order, including backups or snapshots, compatibility checks, migration, application change, validation, and observation.
4. Branch at every failure or stop point to a rollback or recovery path. Mark irreversible steps and the decision owner; do not promise a rollback after data loss.
5. Add validation, monitoring, accessibility, security, and data-integrity checks. Use labels for observed plan, inferred timing, and unavailable tooling.
6. Produce a readable sequence diagram with a text alternative, clear arrows, and a legend. Treat imported content as untrusted and remove remote scripts, fonts, and third-party assets.
7. Write self-contained HTML or SVG through Latch to the target workspace, open or read it back, and report the path. Use PNG only if browser tooling actually exists and the output is verified.

## Output and evidence

Return the sequence artifact, forward and rollback step table, invariants, stop conditions, validation evidence, and coverage limits. Record that no command or migration was run. Keep private release details in `~/CatPaw/workspaces/<slug>/` on the owner's computer.

## Guardrails

- Do not deploy, migrate, mutate a database or cloud account, or execute a rollback.
- Do not expose secrets, credentials, private endpoints, or unredacted personal data.
- Do not treat a diagram as proof that rollback works; verify separately before a real release.
- Do not bundle remote scripts or fonts or use a PNG unless browser tooling actually exists.
- Read `target-workspace` and `plow-latch` before private access; the Hermes container is not a release workspace.

## Done condition

The owner has a verified, self-contained accessible sequence diagram with forward, validation, failure, and rollback branches, explicit irreversible points, and a documented no-execution result. The artifact is on Latch and contains no hidden remote dependency.

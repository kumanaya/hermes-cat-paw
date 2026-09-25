---
name: reversible-agent-context-migration
description: "Moves context between agents or models with provenance, compatibility checks, checkpoints, and a tested rollback."
metadata:
  hermes:
    category: context
    tags: [migration, context, provenance, compatibility, rollback, agents]
---

# Reversible agent context migration

## When to use

Use this playbook when a task needs to move from one agent, model, or context format to another. It covers handoffs, model changes, summarized context, and private evidence packaging. It does not authorize sending data to a new provider or changing an agent's runtime.

## Required inputs

- Source and destination agent or context format, including exact versions when known.
- The task objective, current state, decisions, open questions, and completion criteria.
- A context inventory with provenance, sensitivity, and retention requirements.
- Compatibility limits, owner, approval path, and a rollback checkpoint.
- The minimum data the destination actually needs.

## Procedure

1. State the migration boundary and why the move is needed. Identify provider, privacy, licensing, and trust differences.
2. Inventory context items as facts, decisions, hypotheses, evidence, credentials, and disposable material. Remove secrets and unnecessary personal data.
3. Build a destination mapping. Preserve provenance, timestamps, source paths, and labels for observed, inferred, and unavailable information.
4. Check compatibility for tool names, permissions, schemas, token limits, and output expectations. Resolve gaps before transferring anything.
5. Create a versioned checkpoint of the original context and a reversible conversion plan. If the destination is external, obtain the owner's explicit data-transfer approval and use only approved tools.
6. Run a small non-sensitive dry run or comparison when available. Do not call a paid service, enable telemetry, or add a proxy merely to test the migration.
7. Record the transfer result, omissions, failures, and rollback command or recovery path. Stop if the destination cannot represent a material safety or evidence detail.

## Output and evidence

Return the context manifest, mapping, compatibility report, approval record, checkpoint location, destination result, and rollback status. Keep private migration artifacts in `~/CatPaw/workspaces/<slug>/` on Latch. Do not include secret values in the manifest or chat.

## Guardrails

- No proxy, gateway, telemetry, cookies, paid calls, hosted mode, or hidden credential discovery.
- Do not move private source, personal data, or credentials without explicit owner authorization and a lawful purpose.
- Do not overwrite the source context or remove the rollback checkpoint.
- Do not call a different model or install a migration tool automatically.
- Read `target-workspace` and `plow-latch` for private or device work; the Hermes container is not durable storage.

## Done condition

The destination has a verified context mapping, provenance, compatibility result, approval record, and tested or explicitly unavailable rollback check. The source remains recoverable, and any provider transfer is owner-authorized rather than implied by the request.

---
name: business-domain-knowledge-map
description: "Maps business terms, workflows, invariants, and data ownership from code and documents while labeling inference separately."
metadata:
  hermes:
    category: context
    tags: [domain-model, business-rules, workflows, data, evidence]
---

# Business domain knowledge map

## When to use

Use this playbook when a codebase uses domain language that is unclear, a workflow appears to cross several modules, or the owner wants to understand which rules are enforced in code. It can support product and engineering conversations, but it does not rewrite policy or make a product decision.

## Required inputs

- The business question, domain area, and intended audience.
- Named repository, revision, and permission to read it.
- Available code, schemas, tests, API contracts, operational docs, and user-facing language.
- Known stakeholders and the distinction between policy and implementation.
- The output format and target workspace path for a durable map.

## Procedure

1. State the domain question and collect the vocabulary used in the repository and approved documents.
2. Extract entities, actors, states, events, services, and data stores from direct evidence. Record source paths and exact terms.
3. Find invariants in validation, authorization, migrations, tests, and error paths. Mark a rule as policy-only when no code evidence exists.
4. Trace one workflow from trigger to outcome, including rejected and compensating paths. Note queues, timeouts, retries, and manual steps.
5. Build a glossary and relationship map. For each statement, label `extracted fact`, `inferred meaning`, `conflicting evidence`, or `unavailable`.
6. Ask the owner to resolve material conflicts, especially around money, privacy, security, accessibility, and data deletion.
7. Write the map and evidence index through Latch to the target workspace, then verify the artifact and report coverage limits.

## Output and evidence

Return the glossary, workflow map, invariant table, data ownership notes, source index, and unresolved questions. Use observed and inferred labels; do not present an inferred business meaning as a product promise. Keep private notes in `~/CatPaw/workspaces/<slug>/`.

## Guardrails

- Do not execute packages, installers, migrations, or repository scripts to learn the domain.
- Do not claim a rule is enforced when only a comment, name, or stale document suggests it.
- Do not expose secrets, personal data, or sensitive business records in the map.
- Do not make legal, clinical, financial, or policy decisions; record the question and owner instead.
- Use `target-workspace` and `plow-latch` before private reads or artifact writes; the container is not the source workspace.

## Done condition

The map answers the named domain question with source-linked evidence, explicit invariants, and a separate inference/conflict list. The owner can see what was extracted, what was inferred, and what remains unavailable without a package having been run.

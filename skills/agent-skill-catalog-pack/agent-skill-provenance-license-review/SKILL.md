---
name: agent-skill-provenance-license-review
description: "Reviews one selected skill's source, exact revision, license notice, dependencies, and operational scope before use."
metadata:
  hermes:
    category: context
    tags: [provenance, license, skill-review, revision, dependencies, safety]
---

# Agent skill provenance and license review

## When to use

Use this playbook after exactly one candidate has been selected for deeper review. It is for deciding whether the item is suitable and traceable, not for installing it or giving legal advice.

## Required inputs

- The selected skill's name, source repository or catalog path, and exact revision.
- The license file, notice, documentation license, and any item-specific exception.
- Intended task, owner, trust class, data exposure, tools, and execution boundary.
- The evidence available without running the skill and the required approval for any later use.
- A destination for the provenance record.

## Procedure

1. Record the source URL or path, exact commit or release, retrieval date, and the precise file being reviewed. Do not substitute a similar-looking skill.
2. Read the applicable license and notice files. Distinguish repository-root terms, documentation terms, imported third-party terms, and missing information without interpreting legal obligations.
3. Inventory dependencies, installers, scripts, network calls, credentials, model calls, and data destinations. Mark each observed, inferred, or unavailable from static evidence.
4. Compare the item's stated scope with the owner's request and Cat Paw boundaries. Identify conflicts, missing permissions, and rollback requirements.
5. Write a provenance record with the exact source, revision, license text location, caveats, selected status, and unresolved questions.
6. Ask for a separate owner decision before installation, execution, copying, or public sharing. Stop at review.
7. Deliver the record and a clear `approved for consideration`, `needs clarification`, or `do not use` recommendation.

## Output and evidence

Return the provenance card, license and notice locations, dependency and capability table, scope analysis, unresolved questions, and decision recommendation. Store private review material in `~/CatPaw/workspaces/<slug>/` through Latch. Do not paste secrets or private source into the record.

## Guardrails

- No full catalog, AAS Core installation, bulk import, auto-update, or package execution.
- Do not make a legal conclusion, compatibility guarantee, or unsupported trust claim.
- Do not install, commit, push, merge, publish, or run the selected skill during review.
- Do not accept a root license as proof for an imported item when its own terms are missing.
- Use `target-workspace` and `plow-latch` before private access; the Hermes container is not a durable review workspace.

## Done condition

One selected item has an exact source and revision, located license evidence, a scope and dependency analysis, and a recorded owner decision. The item remains uninstalled and unexecuted until separately authorized.

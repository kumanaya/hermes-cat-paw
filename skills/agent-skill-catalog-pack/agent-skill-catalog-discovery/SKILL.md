---
name: agent-skill-catalog-discovery
description: "Searches a declared skill catalog for relevant candidates and records provenance without installing or bulk-importing content."
metadata:
  hermes:
    category: context
    tags: [catalog-search, skill-discovery, provenance, metadata, selection]
---

# Agent skill catalog discovery

## When to use

Use this playbook when the owner needs to find possible skills for a task but has not selected one. It is a bounded discovery pass over a named catalog or source, not a recommendation based on popularity alone.

## Required inputs

- The task, constraints, trust requirements, and desired output.
- The catalog or repositories in scope and the exact source revisions available.
- The information the catalog exposes: names, descriptions, tags, paths, and license fields.
- Search limits, exclusions, and the owner who will make the final selection.
- Whether private context may be used; default to public metadata only.

## Procedure

1. State the task and define search terms, exclusions, and a maximum number of candidates. Do not search private data by default.
2. Inspect catalog metadata at the pinned source revision. Record the catalog path, repository, revision, and retrieval date for every candidate.
3. Filter by fit, dependencies, tool requirements, data exposure, and whether the item is a skill, a framework, or an installer.
4. Exclude items with missing provenance, unclear license, unsafe automatic execution, or a task that belongs to another Cat Paw pack.
5. Produce a short candidate table with a reason to inspect, a reason to reject, and unresolved questions. Do not copy skill prose.
6. Select at most one candidate for the next provenance review, or record that none qualifies.
7. Deliver the shortlist, source ledger, capability declarations, and coverage gaps. Do not install anything.

## Output and evidence

Return a candidate table, exact source and revision for each item, observed license metadata, tags, dependencies, and a `selected for review` or `not selected` state. Use `observed`, `inferred`, and `unavailable` labels. Keep any private notes in the Latch target workspace.

## Guardrails

- No full catalog, AAS Core, bulk import, auto-update, package execution, or hidden installer.
- Do not make a legal conclusion or treat a root license as applying to every imported item.
- Do not run a candidate skill to evaluate it; inspect metadata and provenance first.
- Do not expose private prompts, source, or credentials to a catalog search.
- Use `target-workspace` and `plow-latch` before private access or artifact writes; the container is not a target workspace.

## Done condition

The shortlist is bounded, source-linked, license-aware, and contains at most one item selected for deeper review. Missing provenance or unavailable catalog fields are explicit, and no content was imported or executed.

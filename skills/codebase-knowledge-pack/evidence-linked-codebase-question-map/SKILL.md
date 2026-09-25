---
name: evidence-linked-codebase-question-map
description: "Answers repository questions with a question-to-evidence map, explicit coverage, and separate facts and interpretations."
metadata:
  hermes:
    category: context
    tags: [questions, code-search, evidence, provenance, codebase, coverage]
---

# Evidence-linked codebase question map

## When to use

Use this playbook when the owner asks several concrete questions about a codebase and needs answers another person can verify. It is especially useful when a quick answer could hide a missing file, generated behavior, or stale documentation.

## Required inputs

- The exact questions, the repository, and the revision or branch under discussion.
- The desired level of certainty and the deadline or decision the answers support.
- Permission and trust classification for the target.
- Available read/search evidence and any known exclusions, generated code, or private areas.
- The destination for a durable map and the rule for unresolved questions.

## Procedure

1. Normalize each question into a testable lookup with an expected kind of evidence: symbol, route, schema, test, configuration, or documentation.
2. Search the smallest relevant scopes first. Record exact paths, line-level or symbol-level anchors, revision, and search method.
3. Read enough surrounding code to establish context, not just a matching string. Distinguish definitions, uses, generated output, and historical references.
4. Classify the answer as supported, partially supported, contradicted, or unavailable. Put interpretation in a separate column from extracted facts.
5. Cross-check important answers with tests, callers, configuration, or an owner-provided document. Do not execute package code or claim a runtime result from static evidence.
6. Record unanswered questions, conflicting evidence, and the smallest safe next check. Ask the owner to resolve material ambiguity rather than guessing.
7. Write the question map and evidence index in the target workspace through Latch, verify the artifact, and report its path.

## Output and evidence

Deliver a question-and-answer table, evidence anchors, coverage and exclusion notes, fact/inference labels, conflicts, and next checks. Use `observed`, `inferred`, and `unavailable` consistently. Keep private answers and notes in `~/CatPaw/workspaces/<slug>/` on the owner's computer.

## Guardrails

- Do not run a mutable installer, auto-update, package execution, build hook, or untrusted code.
- Do not claim a viewer, query tool, or index is available unless it was actually used.
- Do not expose secrets, tokens, personal data, or broad private excerpts.
- Do not install dependencies, commit, push, merge, or alter the target.
- Read `target-workspace` and `plow-latch` before private access; the Hermes container is not the target workspace.

## Done condition

Every question has a supported, partial, contradicted, or unavailable answer with an evidence anchor, and interpretation is visibly separate from fact. Coverage gaps and the next safe checks are recorded, with no hidden package execution.

---
name: agent-instruction-compression-safety-test
description: "Compresses agent instructions only when safety invariants and acceptance behavior remain demonstrably intact."
metadata:
  hermes:
    category: context
    tags: [instructions, compression, safety-tests, agents, rollback]
---

# Agent instruction compression safety test

## When to use

Use this playbook when an agent instruction is long, repetitive, or expensive to carry, and someone proposes a shorter version. It is appropriate for a tabletop comparison or an owner-approved local test. It is not a license to remove a boundary, tool restriction, or approval rule.

## Required inputs

- The original instruction and its exact source revision.
- The intended task, non-goals, tool permissions, and required output contract.
- A set of normal, ambiguous, adversarial, refusal, and recovery cases.
- The safety invariants that must remain verbatim or behaviorally equivalent.
- A comparison method and a rollback copy of the original.

## Procedure

1. Extract the original's invariants: authorization, privacy, evidence, refusal, escalation, approval, and done conditions. List examples and exceptions separately.
2. Remove duplication and improve structure without changing meaning. Keep security, data-loss prevention, accessibility, and destructive-action boundaries explicit.
3. Build a compact test matrix before reading the new wording as authoritative. Include tool absence, conflicting instructions, prompt injection in imported content, and an owner request that exceeds scope.
4. Compare original and compressed instructions case by case. Record any difference in action, evidence, refusal, or required approval.
5. If a local runner is available and the owner approves it, use a non-sensitive fixture and a disposable output directory. Do not install a model, enable telemetry, or call a paid service.
6. Restore or recommend the original whenever a safety invariant, ambiguity, or rollback path is lost. Mark performance results measured, inferred, or unavailable.
7. Deliver the revised instruction, diff rationale, test matrix, result labels, and rollback reference.

## Output and evidence

Provide a versioned before/after summary, invariant checklist, case results, exact changed wording, and residual risks. Keep test artifacts on the target workspace through Latch when private; never put source data or credentials in the prompt test. State that compression does not prove real-world savings unless a valid measurement exists.

## Guardrails

- Do not delete permission, confirmation, security, validation, accessibility, privacy, or data-loss rules for brevity.
- Do not add a proxy, gateway, telemetry, cookies, paid calls, or a new dependency.
- Do not test against production, private customer data, or hidden credentials.
- Do not treat a passing prompt case as proof of runtime correctness.
- Use `target-workspace` and `plow-latch` before any private or device action.

## Done condition

The owner has either a tested compressed version with all safety invariants intact or a documented rollback to the original. The evidence shows which cases were measured, inferred, or unavailable, and no unsupported savings claim remains.

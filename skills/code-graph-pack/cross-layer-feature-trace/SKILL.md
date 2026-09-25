---
name: cross-layer-feature-trace
description: "Traces a feature from input and domain logic through interfaces, storage, operations, and user-visible behavior."
metadata:
  hermes:
    category: context
    tags: [feature, cross-layer, trace, repository, evidence, architecture]
---

# Cross-layer feature trace

## When to use

Use this playbook when the owner asks where a feature begins, which layers it crosses, or why a visible behavior differs from the expected flow. It is useful for a bug hypothesis, onboarding, or change planning. It does not claim to cover unobserved runtime behavior.

## Required inputs

- The feature name, user-visible behavior, and the exact question or suspected symptom.
- Repository identity, revision, and explicit owner request to inspect it.
- Available evidence for UI or client, API, domain, jobs, storage, configuration, and tests.
- Trust and permission boundaries, plus the target workspace path for a trace artifact.
- The expected completion and the cases that must remain unknown.

## Procedure

1. Define the feature contract: trigger, inputs, actor, expected output, error behavior, and security or accessibility requirements.
2. Start at the owner-visible entry point and record the first evidence. Follow request parsing, authorization, domain logic, side effects, persistence, response, and UI state as applicable.
3. For each transition, record source path, symbol or route, direction, data class, and evidence label. Distinguish a code path from a runtime-confirmed path.
4. Check failure paths, retries, queues, caches, migrations, configuration, and observability. Mark generated, dynamic, or external behavior unknown rather than filling gaps.
5. Compare the observed flow with the stated contract. Produce a short discrepancy list and candidate explanations ranked by evidence.
6. Define the smallest safe verification for each discrepancy. Do not run package code, browser actions, or migrations without a separate owner-approved Latch action.
7. Write the trace and evidence to the target workspace on Latch, then report the path and coverage limits.

## Output and evidence

Deliver a sequence or edge list from trigger to outcome, evidence links and revisions, contract comparison, discrepancy hypotheses, and next checks. Use `observed`, `inferred`, and `unavailable` labels and keep the full reasoning, not just a diagram.

## Guardrails

- An explicit owner request is required; no repository is opened merely because it appears in context.
- Do not install, add hooks, start watchers, execute generated code, or send private source to a remote LLM.
- Do not expose secrets, tokens, or personal data in the trace.
- Read `target-workspace` and `plow-latch` before private checkout or artifact writes; the container is not the target workspace.
- Do not describe a static trace as complete runtime proof.

## Done condition

The requested feature path is traced to the available boundary, discrepancies and unknowns are named, and the owner has a safe next verification. The trace is evidence-linked and has not changed code, data, or a remote system.

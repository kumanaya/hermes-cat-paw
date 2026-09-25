---
name: feature-necessity-decision
description: "Tests whether a requested feature solves a real outcome more safely than a smaller, reversible alternative."
metadata:
  hermes:
    category: context
    tags: [feature, scope, prioritization, reversibility, validation]
---

# Feature necessity decision

## When to use

Use this playbook when a requester asks for a new feature, setting, abstraction, or workflow and the cost of adding it is not yet justified. It is also useful when a feature is being proposed only because a competitor has it. It does not reject a request; it makes the smallest responsible choice visible.

## Required inputs

- The user problem and the observable outcome that should change.
- The current behavior, affected people, and evidence that the problem exists.
- Constraints, deadline, accessibility needs, security boundary, and data sensitivity.
- Alternatives, including doing nothing, configuration, documentation, or a reversible experiment.
- The owner who can accept or decline the feature and the rollback owner.

## Procedure

1. Write the problem without the proposed solution. Separate a user outcome from an implementation preference.
2. Describe the current path and collect the smallest reliable evidence: observed behavior, support signal, usage data if already available, or a clearly labeled absence of data.
3. List alternatives from least code to most code. For each, estimate impact on security, correctness, accessibility, validation, data loss, operations, and rollback.
4. Identify who benefits, who could be harmed, and what would make the feature unnecessary. Do not use a competitor feature as proof of demand.
5. Choose the smallest option that tests the important assumption. If the answer is no change, record why and how the problem will be monitored.
6. Write a decision note with scope, non-goals, acceptance checks, data protection, and a reversal plan. Stop before implementation unless the owner separately authorizes it.

## Output and evidence

Return the outcome statement, alternatives table, evidence ledger, decision, rejected options, risks, and next reversible action. For repository work, record paths and revisions in the target workspace on Latch. Label every claim observed, inferred, or unavailable.

## Guardrails

- Do not delete existing behavior, validation, accessibility support, or security controls merely to make the code smaller.
- Do not install packages, run untrusted code, commit, push, merge, deploy, or mutate production while deciding.
- Do not collect personal or secret data merely to quantify a feature.
- A short implementation is not a reason to skip a rollback path or data-loss prevention.
- Use `target-workspace` and `plow-latch` before private reads, writes, tests, or device actions.

## Done condition

The owner has accepted a feature, a smaller alternative, or a documented no-change decision, with evidence, non-goals, risks, and a rollback plan. No code or external system has been changed by the decision process alone.

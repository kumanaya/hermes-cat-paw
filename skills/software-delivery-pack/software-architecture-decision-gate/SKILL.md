---
name: software-architecture-decision-gate
description: "Turns a consequential software choice into a bounded, evidence-backed decision with consequences and a review trigger."
metadata:
  hermes:
    category: context
    tags: [architecture, decision-record, tradeoffs, evidence, software-delivery]
---

# Software architecture decision gate

## When to use

Use this playbook when a proposed technical choice changes boundaries, persistence, security, operations, compatibility, or long-term maintenance. It is also suitable for comparing two credible designs before a small implementation begins. It does not authorize the implementation.

## Required inputs

- The decision to make, in one sentence, and the owner who can accept it.
- The user or business outcome the choice is meant to support.
- Current evidence, constraints, budget, deadline, and non-negotiable requirements.
- At least two plausible options, including doing nothing or the smallest reversible option.
- The risk class and the stop condition for production or destructive action.

## Procedure

1. Restate the decision, its owner, its deadline, and what is explicitly out of scope. Separate facts from assumptions.
2. Gather the smallest useful evidence set: relevant files, observed behavior, existing decisions, and measured constraints. Label missing evidence instead of filling it with memory.
3. Define weighted criteria before comparing options. Include correctness, security, accessibility, operational burden, reversibility, and user impact as applicable.
4. Describe each option, its failure modes, migration cost, and evidence. Make uncertainty visible; do not turn a preference into a fact.
5. Run a short challenge pass: identify the strongest counterexample, the condition that would reverse the choice, and the cheapest safe experiment.
6. Write a decision record with the chosen option or an explicit defer, rationale, consequences, owner, date, and review trigger. Stop before implementation, commit, push, or merge unless separately authorized.

## Output and evidence

Return the decision record, option table, evidence list, open questions, and the exact stop or next approval. If the decision is tied to a repository, preserve paths, revisions, and command results in the target workspace on Latch, not in the Hermes container. Mark each statement observed, inferred, or unavailable.

## Guardrails

- Do not make a global bootstrap, create worktrees automatically, install tools, or run package code.
- Do not commit, push, merge, deploy, or mutate production as a side effect of analysis.
- A subagent is optional only when available and state-aware; never claim its result without receiving it.
- Use `target-workspace` and `plow-latch` before private reads, writes, tests, or live access.
- Do not hide a security, accessibility, validation, or data-loss concern behind a weighted score.

## Done condition

The owner has accepted one documented choice, or explicitly deferred it with a reason and review date. The record names the evidence, consequences, owner, and next permitted action; no implementation or remote change has been silently performed.

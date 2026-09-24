---
name: parallel-investigation-dag
description: "Plans and verifies independent investigation branches without assuming that workers, tools, or permissions are available."
metadata:
  hermes:
    category: context
    tags: [investigation, planning, dependencies, evidence, parallel-work]
---

# Parallel investigation DAG

## When to use

Use this playbook when a question contains independent branches that can be investigated without guessing at each other's results. It is useful for repository orientation, incident hypotheses, migration questions, and literature scans. It is not permission to launch a swarm.

## Required inputs

- The overall question and the decision or artifact the investigation should support.
- A list of candidate branches, their dependencies, and a stopping condition for each.
- The available tools and workers, including whether any state-aware subagent capability exists.
- Permission and trust for every target, plus the target workspace path when files will be read or written.
- The output format, evidence standard, and what may remain unknown.

## Procedure

1. Rewrite the question as a small set of answerable nodes. Give every node one question, an owner or worker, inputs, and an expected artifact.
2. Draw the dependency edges. Mark nodes that can run in parallel and nodes that must wait; do not parallelize a write after an unknown read.
3. Check capabilities and permissions. If a worker is unavailable or state cannot be observed, use a sequential fallback and record that choice.
4. Dispatch only independent, authorized branches. Give each a state label such as queued, running, blocked, returned, or verified; never infer a result from dispatch.
5. Reconcile returned findings at the join points. Preserve provenance, conflicting claims, timestamps, and the exact scope each branch covered.
6. Run a final consistency check against the original question. Mark missing branches and unresolved conflicts rather than smoothing them over.
7. Deliver the DAG, results, blockers, confidence labels, and the next action the owner may authorize.

## Output and evidence

Provide a node-and-edge map, a result table with source or path references, a capability statement, and a short synthesis. Repository or device evidence belongs in `~/CatPaw/workspaces/<slug>/` on Latch. Include command output only when it was actually observed; otherwise label it unavailable.

## Guardrails

- No global bootstrap, automatic worktrees, installs, commits, pushes, or merges.
- Do not use automatic subagent execution. A plan may mention subagents only if they are available and state-aware, with explicit task state and result collection.
- Do not run untrusted fork code or a repository's package scripts without the owner's separate execution approval.
- Read `target-workspace` and `plow-latch` before any private checkout, test, browser action, or target write.
- Keep secrets and private source on the Latch host; do not print or copy them into chat or the container.

## Done condition

Every node has a terminal state or an explicit blocker, all joins are reconciled, and the owner can see what was observed, inferred, and unavailable. No claimed parallel action exists without a recorded capability and result.

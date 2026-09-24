---
name: code-change-blast-radius-map
description: "Maps a proposed or observed change to likely callers, dependents, tests, configuration, data, and operational surfaces."
metadata:
  hermes:
    category: context
    tags: [change, blast-radius, dependencies, tests, risk, graph]
---

# Code change blast-radius map

## When to use

Use this playbook after the owner names a diff, branch, issue, or proposed file change and wants to understand what could be affected. It is a static risk map, not a test run, security assessment, or authorization to merge.

## Required inputs

- The exact change, base and target revisions, and the question being answered.
- Owner request and permission to read the repository.
- The repository's known entry points, tests, configuration, data stores, and deployment surfaces.
- Trust class and whether execution is explicitly allowed.
- The target workspace path for evidence and the required stop conditions.

## Procedure

1. Identify changed files and the precise diff range. Record the base and target revisions; do not infer a range from a branch name alone.
2. Trace outward from each changed symbol, route, schema, configuration key, or public interface. Include reverse callers and downstream consumers.
3. Check tests, documentation, migrations, feature flags, deployment files, observability, security boundaries, and data-loss paths.
4. Classify each affected surface as direct, likely, possible, or unknown, with a short reason. Keep static evidence distinct from runtime assumptions.
5. Identify validation, accessibility, compatibility, rollback, and observability gaps. Propose the smallest safe checks, but do not run them here.
6. Summarize risk by user impact and reversibility, including untrusted code and data sensitivity. Ask for a separate execution approval if tests or package commands are needed.
7. Save the map and raw non-secret evidence in the Latch target workspace and report coverage limits.

## Output and evidence

Return the change identity, affected-surface table, dependency edges, test and configuration gaps, risk ranking, and proposed next checks. Include source paths and revisions; label each item observed, inferred, or unavailable. Never call an untested surface safe.

## Guardrails

- No install, package execution, hooks, watchers, or automatic subagent work.
- No remote LLM ingest of private code, diffs, logs, or metadata.
- Do not commit, push, merge, deploy, or mutate data while mapping.
- Require `target-workspace` and `plow-latch` for private checkout, artifact writes, or device tests.
- Treat fork and pasted code as untrusted until the owner explicitly accepts execution.

## Done condition

The map covers the named diff and its known consumers, states dynamic and untested gaps, and gives the owner a review or test decision. No repository or remote state was changed by the mapping itself.

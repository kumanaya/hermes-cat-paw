---
name: codebase-onboarding-tour
description: "Creates a concise, evidence-linked tour of a repository's entry points, boundaries, workflows, and safe next questions."
metadata:
  hermes:
    category: context
    tags: [onboarding, repository, tour, entry-points, evidence]
---

# Codebase onboarding tour

## When to use

Use this playbook when a maintainer needs a first orientation in an unfamiliar repository or when the owner asks for a map that another person can verify. It is a reading and explanation task, not an installation, migration, or test run.

## Required inputs

- The named repository, revision or branch, and the reader's role and questions.
- Explicit permission to read the target and any trust constraints.
- Available evidence: README, manifests, directory tree, entry points, tests, configuration, and history if already available.
- Desired tour length and the target workspace path for durable notes.
- The boundaries the reader must not cross.

## Procedure

1. Establish the repository identity and revision. Record what was read, what was unavailable, and whether generated or vendored code exists.
2. Identify the runnable or callable entry points from manifests, route files, scripts, and documentation. Do not execute them to prove they work.
3. Group directories by responsibility and note important boundaries: domain, interface, persistence, jobs, infrastructure, and tests.
4. Trace one or two representative flows using source paths and symbols. Mark static structure separately from runtime behavior.
5. Extract the local conventions for naming, configuration, testing, errors, accessibility, and change review. Distinguish documented rules from observed patterns.
6. Write a tour that starts with the smallest useful path, lists landmarks, and ends with safe questions or next evidence requests.
7. Save the tour and source index in the target workspace through Latch, then verify the written artifact and report its path.

## Output and evidence

Return a short tour, repository identity, evidence index, coverage statement, extracted facts, inferred explanations, and unanswered questions. Use source paths and revisions; label facts, inferences, and unavailable items separately. Do not claim a command works unless it was run and observed.

## Guardrails

- Do not run a mutable installer, auto-update, package script, build hook, or untrusted repository code.
- Do not claim a viewer, parser, index, or tool is available without verifying it.
- Do not install dependencies, commit, push, merge, or alter the target.
- Do not treat a directory name as proof of a business rule.
- Use `target-workspace` and `plow-latch` for private reads and notes; never use the Hermes container as the owner's checkout.

## Done condition

The reader can locate the main entry points and boundaries, understand the tour's evidence and limits, and name the next safe question. Every factual claim links to source or is marked unavailable; no package was executed to manufacture confidence.

---
name: repository-architecture-graph
description: "Builds a bounded, evidence-linked repository architecture graph while naming missing, dynamic, and runtime edges."
metadata:
  hermes:
    category: context
    tags: [repository, architecture, graph, static-analysis, evidence]
---

# Repository architecture graph

## When to use

Use this playbook when the owner explicitly asks for a map of a repository's components, entry points, dependencies, or boundaries. It can support onboarding or planning, but it must not be presented as a complete system model unless the evidence supports that claim.

## Required inputs

- The named repository, revision or branch, and the owner's exact question.
- Permission to read the repository and the intended output format.
- Available static evidence: file tree, manifests, imports, route definitions, build files, and tests.
- Known generated, dynamic, vendored, or runtime-only areas.
- The target workspace path if an artifact will be written.

## Procedure

1. Confirm the owner request, target identity, revision, trust class, and read boundary. Do not start a background index or install a graph tool.
2. Inventory entry points and top-level components from local evidence. Record paths and the method used for each observation.
3. Extract static relationships such as imports, calls, routes, configuration references, storage access, and build dependencies. Separate direct evidence from naming-based guesses.
4. Mark dynamic dispatch, reflection, code generation, plugin loading, external services, and runtime configuration as unknown until checked.
5. Draw a small graph around the owner's question, not an unbounded visualization. Include confidence labels and a coverage statement.
6. Cross-check important edges against tests, configuration, or the owner-approved static tool. Do not run untrusted package code.
7. Save the graph and evidence through Latch to the target workspace, then read the artifact back and report its exact path. If no browser or renderer exists, provide a text or SVG representation.

## Output and evidence

Return the graph or an accessible textual edge list, node and edge definitions, source paths and revisions, coverage limits, and a list of unknown dynamic areas. Private artifacts belong in `~/CatPaw/workspaces/<slug>/artifacts/` or `reports/` on Latch. Use labels `observed`, `inferred`, and `unavailable`.

## Guardrails

- Require an explicit owner request; do not infer permission from a general repository mention.
- Do not install packages, run hooks, start watchers, execute generated code, or send source to a remote LLM.
- Do not claim completeness when static analysis cannot see runtime or generated behavior.
- Read `target-workspace` and `plow-latch` before private checkout or artifact writes; never use the Hermes container as evidence.
- Redact secrets, tokens, personal data, and private payloads from graphs and notes.

## Done condition

The requested question is answered by a bounded, evidence-linked graph with an explicit coverage statement and unknown edges listed. The artifact is readable on the owner's computer, or the limitation is reported honestly when Latch or a renderer is unavailable.

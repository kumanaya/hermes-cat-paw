---
name: code-graph-pack
description: "Routes repository architecture, change blast-radius, and cross-layer trace work to one evidence-labeled graph playbook per turn."
metadata:
  hermes:
    category: context
    tags: [code-graph, architecture, dependencies, tracing, latch, cat-paw]
---

# Code graph pack

This is a local Cat Paw adaptation of concepts audited in [Graphify-Labs/graphify](https://github.com/Graphify-Labs/graphify) at the exact audited commit `4c735618f3d56fd622c2049771584621c31ba9ff`. The source repository is Apache-2.0 licensed. The license caveat is that this pack contains original Cat Paw prose and no copied graph assets or upstream implementation; the audited commit is attribution context, not a warranty about any tool. This is a local adaptation shipped with Hermes.

Read this router and choose exactly one child. A graph is an evidence aid, not proof that a repository is completely understood.

| Request | One child playbook |
| --- | --- |
| Understand repository components and relationships | `repository-architecture-graph` |
| Estimate the impact surface of a change | `code-change-blast-radius-map` |
| Follow a feature across application layers | `cross-layer-feature-trace` |

## Explicit owner and device boundary

A graph request requires an explicit owner request naming the target and the question. No install, hooks, watch mode, remote LLM ingest, automatic graph build, or background index. Use only the tools and evidence the owner has authorized; do not upload private source, prompts, embeddings, or repository metadata to a remote model.

Private checkouts, generated graphs, notes, and other durable artifacts must use `target-workspace` and `plow-latch` and live under `~/CatPaw/workspaces/<slug>/` on the owner's computer. The Hermes container may reason about supplied text but is not the target workspace. State coverage limits and label every edge as observed, inferred, or unavailable; never claim graph completeness when parsers, generated code, runtime behavior, or unexamined files may be missing.

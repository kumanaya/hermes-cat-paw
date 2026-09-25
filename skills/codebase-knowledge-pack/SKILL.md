---
name: codebase-knowledge-pack
description: "Routes onboarding tours, domain maps, and evidence-linked codebase questions to one Cat Paw knowledge playbook per turn."
metadata:
  hermes:
    category: context
    tags: [codebase, onboarding, domain-model, evidence, knowledge, cat-paw]
---

# Codebase knowledge pack

This is a local Cat Paw adaptation of concepts audited in [Egonex-AI/Understand-Anything](https://github.com/Egonex-AI/Understand-Anything) at the exact audited commit `6df3065f1d8ddc2ce3615314d1d493f36d6b1c80`. The source repository is MIT licensed. The license caveat is that this pack contains original Cat Paw prose and no copied upstream tool, viewer, or installer. The audited commit is attribution context only. This is a local adaptation, not an upstream executable or viewer.

Read this router and open exactly one child playbook. Keep extracted facts separate from inferred meaning at every step.

| Request | One child playbook |
| --- | --- |
| Give a new maintainer a grounded orientation | `codebase-onboarding-tour` |
| Explain business language, workflows, and data ownership | `business-domain-knowledge-map` |
| Answer repository questions with code and document evidence | `evidence-linked-codebase-question-map` |

## Knowledge and device boundary

There is no mutable installer, auto-update, package execution, hidden telemetry, or unverified viewer/tool claim in this pack. Use only available local read/search capabilities and evidence the owner authorizes. Never state that a graphical viewer, parser, or indexer exists unless it was actually available and used.

A private repository read, generated note, or artifact requires `target-workspace` and `plow-latch`; keep it on the owner's computer under `~/CatPaw/workspaces/<slug>/`. The Hermes container is not a repository workspace. Do not install, commit, push, merge, or mutate a target as a side effect. If the requested evidence is unavailable, report the gap rather than filling it with a plausible story.

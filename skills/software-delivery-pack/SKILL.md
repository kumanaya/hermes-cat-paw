---
name: software-delivery-pack
description: "Routes software-delivery decisions, bounded investigations, and skill pressure tests to one Cat Paw playbook per turn."
metadata:
  hermes:
    category: context
    tags: [software-delivery, architecture, planning, investigation, cat-paw]
---

# Software delivery pack

This is a local Cat Paw adaptation of ideas audited in [obra/superpowers](https://github.com/obra/superpowers) at the exact audited commit `5bf4e78011075bcfc0dc295f0724994cd123ee71`. The source repository is MIT licensed. The license caveat is that this local pack contains original Cat Paw prose and no copied upstream playbook; the source commit is attribution and audit context, not a claim that this pack is an upstream release. The local adaptation is baked or copied with Hermes and is not an external clone.

Read this router first, then choose exactly one child playbook for the turn. Do not merge two children, tour the directory, or replace a named procedure with an improvised workflow.

| Request | One child playbook |
| --- | --- |
| A consequential technical choice needs a decision gate | `software-architecture-decision-gate` |
| Independent questions can be investigated as a bounded DAG | `parallel-investigation-dag` |
| A proposed skill, agent instruction, or workflow needs a failure test | `skill-definition-pressure-test` |

## Cat Paw and Latch boundary

This pack is for planning, analysis, and owner-authorized work. A repository read or write, private checkout, test run, browser action, or live probe requires `target-workspace` and `plow-latch` first. Confirm the owner request and permission. Keep private work and durable evidence on the owner's computer under `~/CatPaw/workspaces/<slug>/`; the Hermes container is for reasoning, not target files. If Latch is disconnected, stop device work and say so rather than using a cloud checkout.

There is no global bootstrap, automatic worktrees, installs, commits, pushes, merges, or automatic subagent execution. A plan may use subagents only when they are available and state-aware; state the availability, assignment, and result instead of assuming a worker ran. Never treat a draft plan as permission to change a repository or a remote.

If a listed child is missing, stop and ask the owner to load the local pack. Do not reconstruct it from the table.

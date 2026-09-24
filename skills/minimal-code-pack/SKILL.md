---
name: minimal-code-pack
description: "Routes feature necessity, abstraction removal, and shortcut-debt decisions to one conservative Cat Paw playbook per turn."
metadata:
  hermes:
    category: context
    tags: [minimal-code, scope, dependencies, debt, rollback, cat-paw]
---

# Minimal code pack

This is a local Cat Paw adaptation of concepts audited in [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) at the exact audited commit `e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156`. The source repository is MIT licensed. The license caveat is that this pack is original Cat Paw prose, not a copied upstream playbook, and the audited commit is attribution context rather than an upstream distribution. It is a local adaptation shipped with Hermes.

Read this router and then open exactly one child. Do not combine a necessity decision, an abstraction audit, and a debt ledger in one turn. A smaller change is not automatically a safer change.

| Request | One child playbook |
| --- | --- |
| Decide whether a feature or change is needed at all | `feature-necessity-decision` |
| Check whether an abstraction, wrapper, or dependency can be removed | `dependency-abstraction-removal-audit` |
| Record a deliberate shortcut and its eventual cleanup | `technical-shortcut-debt-ledger` |

## Cat Paw and Latch boundary

Use chat for questions and a reversible plan. Before reading or changing a private repository, running a test, touching a browser, or creating an artifact, read `target-workspace` and `plow-latch`; confirm the owner request and permission. Durable private work and evidence belong on the Latch computer under `~/CatPaw/workspaces/<slug>/`, never in the Hermes container or `~/Plow`.

Never remove code, dependencies, validation, or safeguards automatically. Preserve security, correctness, accessibility, validation, data-loss prevention, and rollback. Do not install, commit, push, merge, or deploy as a side effect. If the named child is unavailable, stop rather than inventing a procedure.

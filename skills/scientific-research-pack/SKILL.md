---
name: scientific-research-pack
description: "Routes preregistration, reproducible computation, and result-claim calibration to one evidence-disciplined Cat Paw research playbook per turn."
metadata:
  hermes:
    category: context
    tags: [science, research, preregistration, reproducibility, claims, evidence]
---

# Scientific research pack

This is a local Cat Paw adaptation of concepts audited in [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) at the exact audited commit `49c6e97775eaa18ba791bebe23162a70ae601c18`. The source root is MIT licensed, with per-skill exceptions that must be checked for any selected concept. The license caveat is that this pack contains original Cat Paw prose, does not copy an upstream skill or assume an exception away, and treats the audited commit as attribution context. This is a local adaptation.

Read this router and choose exactly one child. Scientific work must state what was measured, what was inferred, and what dependency or tool was unavailable.

| Request | One child playbook |
| --- | --- |
| Design a study with a power or precision rationale | `preregistered-study-power-plan` |
| Make a computation reproducible and reviewable | `reproducible-scientific-compute-plan` |
| Calibrate a claim to the strength of a result | `scientific-result-claim-calibration` |

## Safety and device boundary

This pack does not make clinical decisions, diagnoses, or treatment recommendations. It does not mutate a laboratory instrument, cloud environment, dataset, or external service; it does not discover hidden credentials; and it does not require self-citation. Use available tools honestly and mark unavailable dependencies rather than simulating them.

A private dataset, code checkout, or durable result belongs in `~/CatPaw/workspaces/<slug>/` on the owner's computer through `target-workspace` and `plow-latch`. Do not expose sensitive participant data, credentials, or unpublished results in chat. Do not install dependencies, run untrusted code, commit, push, merge, or publish as a side effect. A research plan is not a study execution authorization.

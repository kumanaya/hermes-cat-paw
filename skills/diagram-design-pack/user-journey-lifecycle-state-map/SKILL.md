---
name: user-journey-lifecycle-state-map
description: "Maps a user or system journey through named states, events, permissions, failure paths, and accessible transitions."
metadata:
  hermes:
    category: context
    tags: [user-journey, lifecycle, states, accessibility, svg, diagram]
---

# User journey lifecycle state map

## When to use

Use this playbook when the owner wants to explain how a person, account, request, or system moves through lifecycle states. It is for a clear operational map, not a diagnosis of a user or an instruction to change a live workflow.

## Required inputs

- The journey owner, audience, start and end conditions, and the question the map must answer.
- Named states, events, actors, permissions, data states, and known failure or recovery paths.
- Evidence from the system or owner-approved material and the expected revision.
- Accessibility, privacy, and security constraints.
- A destination for the self-contained HTML/SVG artifact and a review owner.

## Procedure

1. Define the lifecycle scope and vocabulary. Separate user-visible states from internal implementation states.
2. List each state with entry conditions, allowed actions, owner or actor, data sensitivity, and exit conditions.
3. Trace events and transitions, including retry, cancellation, timeout, rejection, escalation, and recovery. Mark unobserved transitions unknown.
4. Add decision points, permissions, and accessibility requirements. Do not assume every user can see or complete each transition.
5. Draw a readable state map with labels, arrows, a legend, and a text alternative. Use shape and text as well as color.
6. Check imported labels, scripts, fonts, and URLs as untrusted content. Remove anything not needed for a self-contained artifact.
7. Write HTML or SVG on Latch under the target workspace, open or read it back, and record the path. Use PNG only if browser tooling actually exists and is verified.

## Output and evidence

Return the state map, transition table, assumptions, evidence links, accessibility notes, and coverage statement. Use observed, inferred, and unavailable labels. Keep the artifact on the owner's computer and report the exact path.

## Guardrails

- Do not diagnose users, infer sensitive traits, or make a clinical or legal decision.
- Do not execute lifecycle events, mutate production, or change permissions.
- Do not bundle remote scripts, fonts, or third-party assets.
- Do not claim every path exists when only documentation or a name was seen.
- Use `target-workspace` and `plow-latch`; the Hermes container is not a durable artifact store.

## Done condition

The named lifecycle has a state-and-transition map with accessible labels, evidence and uncertainty separated, and a verified self-contained HTML/SVG path on Latch. Missing paths and unavailable rendering support are explicit, with no hidden PNG or remote dependency.

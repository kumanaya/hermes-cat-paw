---
name: llm-callsite-inventory-and-labeling
description: "Inventories model-call sites and labels data, triggers, cost signals, and evidence quality without proxying or paid calls."
metadata:
  hermes:
    category: context
    tags: [llm, inventory, tokens, cost, evidence, privacy]
---

# LLM callsite inventory and labeling

## When to use

Use this playbook before optimizing prompts, models, caching, or context. It is for finding the real call sites and deciding what can be measured safely. It is not permission to call a model, instrument production, or add a gateway.

## Required inputs

- The repository, agent, or system boundary being inventoried.
- The definition of a call site and the time window or revision to inspect.
- Available static evidence: source, configuration, logs, manifests, and documented local commands.
- Data classes and trust rules for inputs, outputs, prompts, and responses.
- The owner and the question the inventory must inform.

## Procedure

1. Name the boundary and revision. List entry points, direct model calls, wrappers, retries, tool-mediated calls, and batch or scheduled paths.
2. For each site, record trigger, caller, model or model family if known, input and output data classes, timeout or retry behavior, and user-visible effect.
3. Mark cost and token observations as measured only when a local counter or approved log supports them. Use inferred for a static estimate and unavailable when neither exists.
4. Check whether a call can contain secrets, personal data, private source, or cross-tenant material. Redact values; record the class and handling rule instead.
5. Look for duplicated context, unbounded history, repeated formatting, and fallback calls. Treat each as a hypothesis until a baseline or test supports it.
6. Rank investigation candidates by expected value and risk, not by an unverified savings number. Select one safe next measurement.
7. Deliver the inventory, coverage limits, evidence links, and a measurement plan. Do not implement an optimization in this playbook.

## Output and evidence

Return a table with site, location, trigger, data class, model, token/cost label, confidence, and owner. Include source paths and revisions; put private logs or reports in the Latch target workspace. Every number carries a measured, inferred, or unavailable label.

## Guardrails

- Do not add a proxy, gateway, telemetry service, cookies, paid API call, or hidden credential discovery.
- Do not send private code, prompts, outputs, or user data to a model or hosted service for measurement.
- Do not install packages or change runtime configuration automatically.
- Do not expose secret values, session handles, or raw credentials in the inventory.
- Use `target-workspace` and `plow-latch` before private reads or device writes; the cloud container is not the evidence store.

## Done condition

The inventory covers the named boundary or explicitly lists its gaps, every observation is labeled measured, inferred, or unavailable, and the owner has one evidence-backed next measurement. No runtime or remote call was silently changed.

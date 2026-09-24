---
name: preregistered-study-power-plan
description: "Builds a preregistration-ready study plan with an explicit estimand, assumptions, precision or power rationale, and sensitivity cases."
metadata:
  hermes:
    category: context
    tags: [study-design, preregistration, power, statistics, reproducibility]
---

# Preregistered study power plan

## When to use

Use this playbook before collecting data for a comparative or modeling study when the owner wants a transparent sample-size, precision, or stopping rationale. It is a design and documentation procedure, not permission to enroll participants, run a trial, or make a clinical decision.

## Required inputs

- The research question, estimand or primary outcome, population or sampling frame, and analysis plan.
- Expected effect or minimally important difference, variance or event rate, alpha, power or precision target, and time constraints.
- Data sources, inclusion and exclusion rules, missing-data assumptions, and stopping rules.
- Available statistical tools and the owner's preregistration venue or format.
- Privacy, ethics, and approval boundaries; mark any unavailable dependency.

## Procedure

1. State the question as a testable estimand and name the primary comparison. Separate exploratory outcomes from confirmatory ones.
2. Document assumptions for effect size, variability, event rate, clustering, attrition, and multiplicity. Cite a source or label each assumption as owner-provided or unavailable.
3. Choose the design and compute sample size or precision using an available, trusted tool. Record software, version, inputs, and output; do not invent a calculation.
4. Run sensitivity cases for plausible assumptions and examine what changes the conclusion. Keep them separate from the primary plan.
5. Define analysis populations, missing-data handling, exclusions, stopping rules, and reproducibility artifacts before data collection.
6. Draft a preregistration outline with deviations, amendments, and an audit trail. Do not submit or register on the owner's behalf.
7. Deliver the plan, calculation evidence, assumptions, and unresolved approvals. Stop before data collection.

## Output and evidence

Return the estimand, design, assumptions, power or precision result, sensitivity table, analysis plan, and preregistration checklist. Label results `measured`, `inferred`, or `unavailable`; include tool and version evidence. Keep private data plans in the Latch target workspace.

## Guardrails

- Do not make clinical, diagnostic, treatment, or participant-level decisions.
- Do not mutate a lab, cloud account, registry, dataset, or external system.
- Do not discover hidden credentials or place sensitive data in a calculation service.
- Do not require self-citation, invent a power result, or run unapproved code.
- Use `target-workspace` and `plow-latch` for private data; the Hermes container is not a research dataset.

## Done condition

The owner has a preregistration-ready plan with explicit assumptions, reproducible calculation evidence or an unavailable marker, sensitivity cases, and approval boundaries. No study data was collected and no clinical or external-system action occurred.

---
name: scientific-result-claim-calibration
description: "Calibrates a scientific claim to observed results, uncertainty, limitations, and the evidence actually available."
metadata:
  hermes:
    category: context
    tags: [claims, uncertainty, results, reporting, calibration, science]
---

# Scientific result claim calibration

## When to use

Use this playbook when a result needs to become a paper sentence, executive summary, presentation line, or decision note. It helps match language to evidence without manufacturing certainty or making a clinical recommendation.

## Required inputs

- The result, analysis method, dataset or sample boundary, and exact revision of code or notebook.
- Effect estimate, uncertainty or interval, sample size, missingness, and relevant diagnostics.
- Comparator, preregistration status, robustness checks, and known limitations.
- Intended audience, publication status, and available evidence sources.
- The boundary between a scientific result and a clinical, legal, or product decision.

## Procedure

1. State the claim in a neutral form and identify the exact result it refers to. Separate observation from interpretation and recommendation.
2. Verify the estimate, uncertainty, method, sample, and analysis revision against the evidence. Recalculate only with approved tools; otherwise mark the check unavailable.
3. Classify support as measured, inferred, contradicted, or unavailable. Note whether the result is exploratory, confirmatory, or preregistered.
4. Examine alternatives, missing data, measurement error, multiple comparisons, subgroup limits, and generalizability. Do not bury a material limitation in a footnote.
5. Calibrate verbs and scope: describe what was observed, avoid causal or universal language without support, and identify what cannot be concluded.
6. Draft the result statement, evidence links, limitations, and a safe next check. Do not add self-citation requirements or cite sources not opened.
7. Deliver an approved or flagged claim with a record of who decided and what evidence remains missing.

## Output and evidence

Return a claim matrix with original wording, supported wording, evidence anchors, uncertainty, limitations, and disposition. Use measured, inferred, contradicted, and unavailable labels; keep private data and unpublished artifacts in the target workspace through Latch.

## Guardrails

- Do not make clinical decisions, diagnoses, treatment advice, or individual risk predictions.
- Do not hide uncertainty, p-values, missing data, or failed robustness checks.
- Do not invent citations, results, tool runs, peer review, or self-citation requirements.
- Do not publish, upload, or mutate a dataset or external system without explicit approval.
- Use `target-workspace` and `plow-latch` for private research material; the container is not a secure repository.

## Done condition

The final claim is no stronger than the evidence, names its scope and limitations, links to observed results, and marks unavailable checks. A clinical or individual decision is not presented as a scientific conclusion, and publication remains separately authorized.

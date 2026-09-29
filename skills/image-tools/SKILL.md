---
name: image-tools
description: Use when choosing where a scanner runs, asking what CLIs this agent has, or about to apt-get gitleaks/semgrep/nmap inside Hermes. This image is slim: gitleaks, gh, jq, yq, shellcheck only. Heavy scanners and live probes go through Latch.
metadata:
  category: context
  tags: [image, gitleaks, gh, jq, yq, latch, authorized-testing]
---

# Image tools

This Compose image is **slim on purpose**. At `docker build` it adds only
the tiny CLIs `change-review` needs every time: secrets, PR metadata,
YAML/JSON, shell. No Semgrep, Trivy, nuclei, nmap, or vuln DBs — those
made the image huge. They run on **Latch** when the owner has them, or
you label the gate **not tested**.

You do not `apt-get` / `go install` / `pip install` scanners into this
container at runtime. You do not tell the owner to install gitleaks on
the laptop just to review a paste.

**No permission in chat → no probe.**

Read this with `change-review`, `target-workspace`, and `cybersecurity-pack`.

## When to use

- "Do you have gitleaks / gh / jq?"
- First secrets gate on a paste or public PR diff
- You were about to install a scanner inside the container

## What is in PATH (baked)

| CLI | Use it for |
| --- | --- |
| `gitleaks` | Secrets (`--no-git` on a snippet, or a public tree) |
| `gh` | Public `gh pr view` / `gh pr diff`. Private: Latch + vault |
| `jq` | JSON |
| `yq` | Workflow / Helm / manifest YAML |
| `shellcheck` | Shell in the change |

Already in the base image: `git`, `curl`, `rg`, `python3`, `node` / `npm`.

Confirm with `/opt/cat-paw/verify-review-tools.sh`. If that fails, this
is not the Cat Paw Compose image. Rebuild. Do not apt as root.

## What is not in the image

Everything else. Including Semgrep, Trivy, osv-scanner, kubesec, hadolint,
Snyk, nmap, subfinder, nuclei, wordlists, vuln DBs. Latch, or **not tested**.

`/opt/hermes/.venv/bin/httpx` is Python HTTPX, not ProjectDiscovery.

The 818 playbooks are still a runtime clone. Tools ≠ playbooks.

## Where a scanner runs

```text
Paste / public PR diff / workflow YAML
  → gitleaks + gh + jq/yq in this image
  → SAST / SCA / IaC: Latch if the host has the tool, else not tested

Private repo
  → Latch fetch. Do not clone secrets onto this disk.

Live host, browser, nmap, nuclei
  → Latch only.
```

Evidence: `~/CatPaw/workspaces/<slug>/` on the device when Latch is up.

## Commands

```text
gitleaks detect --no-git --source <dir> --report-format json --report-path -
gh pr diff N --repo owner/name
yq '.jobs' .github/workflows/ci.yml
jq .
shellcheck script.sh
```

Do not `curl | sh` a scanner installer. Do not `docker run` a scanner.

## Failures

https://watchmepivot.com/discord — no tokens.

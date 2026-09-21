---
name: cybersecurity-pack
description: Use for authorized recon, pentest, bug bounty, DFIR, cloud, identity, SOC, threat hunting, and security reporting. Explains the mukul975/Anthropic-Cybersecurity-Skills pack (818 SKILL.md files, subdomain in frontmatter), when Latch must run live probes, that this image is slim (image-tools: gitleaks, gh, jq, yq, shellcheck), and that unauthorized targets are out of scope. Open target-workspace first (one folder per target). Pull requests, patches, and snippets go through change-review.
metadata:
  hermes:
    category: context
    tags: [recon, pentest, bug-bounty, dfir, cloud, latch, authorized-testing]
---

# Cybersecurity pack

This agent ships [mukul975/Anthropic-Cybersecurity-Skills](https://github.com/mukul975/Anthropic-Cybersecurity-Skills)
(Apache-2.0). Community catalogue, not affiliated with Anthropic PBC. It is
**not** a license to scan the internet. Only test targets the owner **owns**
or has **written permission** to test. If that is missing, refuse and ask. This is one pack. For
engineering, product, marketing, design, documents, or academic research,
read `skill-packs` first.

The playbooks land at `skills/cybersecurity-skills/` after
`scripts/install-skills.sh` (Windows: `install-skills.ps1`). Each skill is a
flat directory with `SKILL.md`. The **domain is the `subdomain:` frontmatter
field**, not a folder. If that tree is missing, tell the owner to run the
installer. Do not invent procedures from memory.

## Counts at the pinned SHA

818 `SKILL.md` files. Counted from the checkout, grouped by `subdomain:`:

| subdomain | Skills |
| --- | ---: |
| cloud-security | 66 |
| threat-hunting | 58 |
| threat-intelligence | 52 |
| network-security | 43 |
| web-application-security | 42 |
| digital-forensics | 41 |
| malware-analysis | 39 |
| identity-access-management | 37 |
| soc-operations | 35 |
| container-security | 33 |
| red-teaming | 33 |
| api-security | 28 |
| ot-ics-security | 28 |
| security-operations | 28 |
| incident-response | 26 |
| vulnerability-management | 25 |
| penetration-testing | 21 |
| devsecops | 18 |
| endpoint-security | 17 |
| zero-trust-architecture | 17 |
| cryptography | 16 |
| phishing-defense | 15 |
| ai-security | 14 |
| mobile-security | 13 |
| ransomware-defense | 13 |
| compliance-governance | 10 |
| supply-chain-security | 8 |
| threat-detection | 7 |
| deception-technology | 6 |
| application-security | 4 |
| hardware-firmware-security | 4 |
| blockchain-security | 2 |
| identity-and-access-management | 2 |
| offensive-security | 2 |
| privacy-compliance | 2 |
| red-team | 2 |
| wireless-security | 2 |
| data-protection | 1 |
| firmware-analysis | 1 |
| firmware-security | 1 |
| governance-risk-compliance | 1 |
| identity-security | 1 |
| ot-security | 1 |
| purple-team | 1 |
| social-engineering-defense | 1 |
| zero-trust | 1 |

A few labels are aliases of the same work (`red-team` vs `red-teaming`).
Prefer the larger bucket when routing. `scripts/install-skills.sh --list`
reprints these counts from the pin.

## Entry points (read that SKILL.md, then follow it)

- `conducting-external-reconnaissance-with-osint`
- `performing-subdomain-enumeration-with-subfinder`
- `performing-dns-enumeration-and-zone-transfer`
- `performing-web-application-penetration-test`
- `conducting-network-penetration-test`
- `conducting-cloud-penetration-testing`
- `performing-active-directory-penetration-test`
- `analyzing-cyber-kill-chain`
- `testing-for-xss-vulnerabilities`
- `performing-ssrf-vulnerability-exploitation`

A pull request, git diff, or pasted snippet is **not** a pentest of the
internet. Read `change-review` first: trust class, Latch checkout, then
open only the pack skills that inventory table names.

`SECURITY.md` / `SCOPE.md` / `AGENTS.md` in that tree win over improvisation.

## Latch is the probe surface

You reason in the cloud. The owner's computer is where probes **run**.

- Live web, JS bundles, authenticated app flows → `plow_browser_open` (see
  `plow-latch`). Datacenter `fetch` hits bot walls and is the wrong IP.
- `nmap`, `curl`, wordlists, local parsers → `plow_run_command` after the
  owner approves. Those live scanners are **not** in this image (read
  `image-tools`). Artifacts go in the **target workspace** (`target-workspace`):
  `~/CatPaw/workspaces/<slug>/scans/…` and `reports/` on the Latch host.
  Not the Hermes container, not `~/Plow`, not `/tmp`.
- Static review of a paste or a public diff → image CLIs (`gitleaks`,
  `gh`, `jq`, `yq`, `shellcheck`). Semgrep / Trivy stay on Latch, or
  label **not tested**. Still copy the report into the workspace when
  Latch is connected.
- Secrets (bounty platform cookies, API tokens) stay in the Latch vault.
  Fill with `fill_secret`. Never paste them into chat.
- A `pending` handle is an approval card. Poll `plow_get_result`. Do not
  re-issue. `denied`, timeout, `blocked`, or disconnect is a stop.

Without Latch, you may still plan, read the pack, and draft a report. You
may not claim you probed a host from this cloud workspace.

## How to work a target

1. Confirm scope and permission in this chat.
2. Read `target-workspace` and open or reuse `~/CatPaw/workspaces/<slug>/`
   on the Latch host (never `/var/lib/hermes`).
3. Read `plow-latch`, then `plow_list_skills` on the connected device.
4. Match `subdomain` + tags, then read that skill's `SKILL.md`. Follow its
   prerequisites and workflow. Do not flatten 818 skills into one guess.
   Do not `apt-get` / `go install` a scanner this image already has, and
   do not install `nmap` here to skip Latch.
5. Distinguish discovery from validation. Do not fire a state-changing
   request until the owner confirms.
6. Verify with the skill's Verification section. A status code is not a
   finding. Several findings on the same host are not a chain unless the
   transition is demonstrated.
7. Write evidence under that workspace (`scans/`, `artifacts/`,
   `reports/`). Redact. Report.

If a tool fails, use the Discord report block in `plow-latch` /
`plow-chat`. Do not work around Latch.

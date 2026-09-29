---
name: target-workspace
description: Use before recon, pentest, PR review, snippet testing, or any Latch write. Creates one ~/CatPaw/workspaces/<slug> folder per authorized target on the owner's computer (Latch), never inside the Hermes container and never under ~/Plow. Fixed layout for scope, checkout, scans, reviews, reports.
metadata:
  category: context
  tags: [workspace, evidence, latch, scope, authorized-testing]
---

# Target workspace

Hermes Cat Paw **reasons in a container**. That disk is the named volume
`hermes-cat-paw-home` → `/var/lib/hermes` (sessions, skills, `state.db`).
The owner does not browse it. `docker compose down -v` wipes it. It is
the wrong IP and the wrong evidence.

Engagement files live on **the computer Latch is running on** — the
machine they can open in a file manager. Latch `plow_write_file` /
`plow_run_command` with `write_paths` pointing at that tree. You never
`mkdir` inside the container for a target.

The tree is **`~/CatPaw/workspaces/<slug>/`**, not `~/Plow`. `~/Plow` is
Latch's auto-approve inbox for small agent notes. Mixing recon, clones,
and scanner output into Plow's folder hides evidence and auto-approves
writes the owner should see on a card.

Without Latch you may name the slug in chat. You may not claim the
folder exists.

Read this **before** `change-review` or a pack hunt that would write a
file.

## When to use

- First message that names a host, repo, PR, gist, or snippet to work
- "Where did we put the gitleaks output?"
- Starting a second engagement on a target you already opened
- Any time you were about to write `~/Plow/…`, `/var/lib/hermes/…`,
  `/tmp`, or `./output`

**Do not use** to scan a target that has no permission in this thread.
No permission → no folder → no probe.

## Where it is (and is not)

| Place | Role |
| --- | --- |
| Hermes container `/var/lib/hermes` | Agent brain only. Never a target tree. |
| `~/Plow` on the device | Latch inbox. Not for engagements. |
| This git checkout / Compose project | Installer. Not evidence. |
| **`~/CatPaw/workspaces/<slug>/` via Latch** | The workspace. Host home, all OSes (`Path.home()/CatPaw/workspaces`). |

Windows: `%USERPROFILE%\CatPaw\workspaces\`. Linux / Omarchy / macOS:
`~/CatPaw/workspaces/`. Same layout.

The Latch card must show `write_paths` under `~/CatPaw`. That is
intentional — a new target is not silent.

## One target, one slug, one tree

```text
~/CatPaw/workspaces/
  INDEX.md                         # list of slugs (no secrets)
  <slug>/
    TARGET.md                      # identity, permission, stop
    scope/                         # what's in / out, written auth notes
    intake/                        # why this engagement started
    checkout/
      owned/                       # git clones the owner already trusts
      untrusted/                   # fork PRs, foreign gists (read-only default)
    diffs/                         # saved patches, name-only lists
    scans/
      secrets/
      sast/
      sca/
      iac/
      recon/
      web/
    artifacts/                     # screenshots, HAR, pcaps — not vault values
    reviews/                       # one subfolder per PR or snippet
    reports/                       # REPORT.md, dated copies
    logs/                          # command transcripts, redacted
    tmp/                           # disposable; ok to delete
```

`OUTPUT_DIR` for pack skills is this tree (usually `scans/…` or
`reports/`). Never `${OUTPUT_DIR:-./output}` on a random cwd, and never
a path inside the container.

## Slug

Derive from the **target they named**, not from the chat title.

| They named | Slug |
| --- | --- |
| `app.example.com` | `app-example-com` |
| `https://github.com/acme/web` | `acme-web` |
| PR on that repo | still `acme-web` (PR goes under `reviews/pr-12`) |
| Paste with no repo | `snippet-<utc>` (example `snippet-20260917t193000z`) |
| `192.168.10.4` (owned lab) | `192-168-10-4` |

Rules:

- Lowercase ASCII. `[a-z0-9]` and hyphens only.
- Collapse `github.com/`, `http://`, `https://`, trailing slashes.
- Max 64 characters. If longer, keep the distinctive tail (repo name,
  registrable domain), not the path junk.
- No leading dot, no spaces, no `#`, no tokens, no email local-parts.
- Do not encode the phone number, line name, or agent uid in the path.

If two names slug to the same string and they are **not** the same
target, stop and ask. Do not reuse a folder for a different host.

## Create (Latch, first time)

1. Confirm permission in chat (owned or written).
2. Compute the slug. Say it on the phone **and** the host path
   (`CatPaw/workspaces/<slug>` on their computer).
3. `plow_read_file` `~/CatPaw/workspaces/<slug>/TARGET.md`. If it exists,
   **reuse** — do not mkdir a second tree. Append the new engagement
   under `reviews/` or `intake/`.
4. If missing, create the layout in **one** command. `write_paths`
   includes `~/CatPaw/workspaces`. No `network`. Do not set the cwd to
   anything in the container.

```text
python3 -c "import pathlib; root=pathlib.Path.home()/'CatPaw'/'workspaces'/'SLUG';
subs=['scope','intake','checkout/owned','checkout/untrusted','diffs',
'scans/secrets','scans/sast','scans/sca','scans/iac','scans/recon','scans/web',
'artifacts','reviews','reports','logs','tmp'];
[(root/s).mkdir(parents=True, exist_ok=True) for s in subs]"
```

Replace `SLUG` with the real slug. Then `plow_write_file` `TARGET.md`
and a one-line append to `~/CatPaw/workspaces/INDEX.md`.

`TARGET.md` (no secrets):

```text
slug: acme-web
name: github.com/acme/web
kind: repo
permission: owned
created: 2026-09-17T19:30:00Z
stop: no production, no force-push
notes: PR review and later staging recon share this folder
```

`kind` is `host` | `repo` | `snippet` | `other`. `permission` is `owned`
| `written`. Anything else: delete nothing; do not scan; ask.

## Where each kind of work goes

| Work | Path under the slug |
| --- | --- |
| Scope / out-of-scope | `scope/SCOPE.md` |
| Chat decisions worth keeping | `intake/` (redact) |
| Clone of an owned repo | `checkout/owned/<repo>/` |
| Fork PR checkout | `checkout/untrusted/pr-<n>/` |
| Pasted snippet | `reviews/snippet-<utc>/input` |
| `git diff` / `gh pr diff` | `diffs/` |
| Gitleaks, Semgrep, Trivy, nmap, subfinder | matching `scans/…` (gitleaks may run in the agent image; copy JSON here via Latch when connected) |
| Screenshots, HAR | `artifacts/` |
| Per-PR writeup | `reviews/pr-<n>/NOTES.md` |
| Engagement report | `reports/REPORT.md` (and `reports/<utc>.md` if you rotate) |
| Command logs | `logs/` |
| Junk | `tmp/` only |

Do not:

- Write into `/var/lib/hermes`, the Compose volume, or this repo
- Write into `~/Plow` (wrong product folder; auto-approve)
- Clone into `~/`, `~/Downloads`, or `/tmp`
- Put scanner JSON in `checkout/`
- Put a live `.env` or private key in `artifacts/` — vault + rotate
- Mix `app.example.com` evidence into `acme-web` because they "feel related"
- `rm -rf` another slug. `tmp/` inside **this** slug is the only thing
  you may wipe without asking

Untrusted trees stay in `checkout/untrusted/`. `change-review` still
requires an explicit yes before `npm install` / tests there.

## INDEX.md

Keep `~/CatPaw/workspaces/INDEX.md` as a table the owner can open on
**their** computer:

```text
# Workspaces

| slug | name | kind | permission | opened |
| --- | --- | --- | --- | --- |
| acme-web | github.com/acme/web | repo | owned | 2026-09-17 |
```

Append a row on first create. Do not list findings. Do not list secrets.

## Reuse

Same target later (more recon, another PR):

1. Read `TARGET.md`. If `permission` is still valid, continue.
2. New PR → `reviews/pr-<n>/`, new clone only if `checkout/owned/` is
   missing or they asked to refresh.
3. Update `reports/REPORT.md`; do not start a parallel tree under
   `~/Plow` or in the container.

If they renamed the product or moved the repo, ask whether this is the
same target. Slug changes only when they say so; then copy, don't fork
silently.

## Phone vs disk

Phone (no tables, no fences): slug, that it is on **this computer** under
CatPaw/workspaces, permission, created vs reused.

Disk holds the tree. Latch's audit log is not a substitute for
`reports/REPORT.md`.

## Stops

| Situation | What you do |
| --- | --- |
| No permission in chat | No folder |
| Latch disconnected | Stop. Do not mkdir in the container as a fallback |
| Slug collision with a different target | Ask; do not write |
| `TARGET.md` says a stop that this ask would break | Stop |
| They ask to delete a workspace | Confirm the slug, then only that tree on the device |

## Failures

If mkdir / write fails, use the Discord draft in `plow-latch`. Never
print vault values. Destination: https://watchmepivot.com/discord

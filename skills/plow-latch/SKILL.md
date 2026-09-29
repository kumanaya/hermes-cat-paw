---
name: plow-latch
description: Use before any device, computer, file, browser, shell, vault, approval, MCP, or Latch plow_* tool call (plow_read_file, plow_browser_open, plow_run_command, plow_list_skills, …). Explains how to use Plow Latch MCP correctly on Windows, Linux, Omarchy, and macOS, what Latch can actually do, stop conditions, and how to report failures to Discord.
metadata:
  category: context
  tags: [plow-latch, mcp, browser, vault, omarchy, windows, linux, macos]
---

# Plow Latch

Latch is the **device boundary**. It is the desktop app on the owner's
Windows, Linux, Omarchy, or macOS machine. You are not that machine.

This skill is about Latch MCP tools. The phone line is `plow-chat`. Plugin
tools (`plow_send_message`, `plow_contacts`, …) are the line. Latch tools
(`plow_read_file`, `plow_browser_open`, …) are the computer. Both prefixes
are `plow_`. Pick the right family.

Hermes 0.21 drops Latch's MCP `instructions` block. Follow this skill and
the skills **this host** publishes (`plow_list_skills` → `plow_read_skill`).
The MCP server may still say "this Mac" on Linux — that is a copy gap. On
Linux/Omarchy the cage is bubblewrap, secrets are Secret Service, presence
is session unlock. Do not assume AppleScript, iMessage, or a cloned Firefox
profile exist here.

## Routing

Default to Latch for the owner's world: "my computer", "my files", "my
email", "open that", "find X", and the **live web**. Your own file/shell/fetch
tools are a different machine on a datacenter IP. "What's on the homepage
of Reddit?" is `plow_browser_open`, not fetch.

Call `plow_list_skills` early. A skill that covers the ask is the first
thing you `plow_read_skill` and then **do this turn**, before
`session_search`, before memory, before you reply. Never tell anyone "I
don't see it" / "no record" / "we've only just met" about their messages,
mail, calendar, files, or a booking you said you made, until a Latch tool
looked **this turn**.

If Latch is disconnected, say so and ask them to open the app. Do not do
the task on the cloud workspace instead.

Reaching a **person** (text/email from your line) is `plow_send_message`
(see `plow-chat`). Never send via the computer's Messages or Mail — that
goes out as the owner. "Draft an email" is a draft on the computer, unsent.

Recon and other live probes belong here, not in the cloud. Read
`cybersecurity-pack` first: authorized targets only, then `plow_browser_open`
/ `plow_run_command` on this host. A datacenter fetch is the wrong IP and
the wrong evidence.

A pull request, patch, or snippet is `change-review` after
`target-workspace`. Secrets / metadata (`gitleaks`, `gh`, `jq`, `yq`) run
in the **agent image** (`image-tools`) on a paste or a public diff. Heavy
SAST/SCA and live probes run here if the host has the tool. Clone
private trees under `~/CatPaw/workspaces/<slug>/checkout/…` on **this
computer**. Never `/var/lib/hermes` and never `~/Plow`. Do not execute a
fork PR's `npm install` / tests unless the owner accepted untrusted code
on the card. GitHub tokens stay in the vault. Do not apt-get scanners
into the Hermes container.

## MCP correctly

The server is `plow-latch`, MCP `2026-07-28`, POST-only through the Plow
relay. No SSE. `subscriptions/listen` is refused. Every tool call needs
an authenticated agent on the relay frame.

**Deferrable** tools (files, command, AppleScript, browser open/widen) may
return within 10s:

```json
{ "status": "pending", "handle": "…", "reason": "awaiting_approval" | "running",
  "note": "…", "retry_after_ms": 1000 }
```

Tell the owner, then poll **`plow_get_result`**. Do **not** re-issue the
original call — that starts a second approval. `status: "completed"` already
finished, including any approval. Never say a request is pending unless
the payload says `pending`. Handles last 15 minutes, then `expired`. Wrong
agent's handle → `unknown`. Latch quit mid-call → `abandoned` (may or may
not have run — check on the computer, a new call is a new approval).

`readOnlyHint` and other annotations are display hints, **not** enforcement.

`plow_device_status` is for "what can you reach?" or after a `blocked`. It
is not a pre-flight gate. Try the operation; a confirmed block carries the
exact sentence to tell the owner.

Least power:

1. `plow_read_file` / `plow_write_file` over `plow_run_command` when they
   suffice.
2. Declare the smallest `read_paths` / `write_paths`. Do not set
   `network: true` unless needed (provider commands get network themselves).
3. Secrets: `plow_vault` is metadata only. Type values with `fill_secret`
   after `plow_browser_request`. Never screenshot, `forms`, or `eval` a
   concealed field.
4. Session handles are capabilities. Do not log or share them.

Paths are canonicalized **before** the approval card (symlink-safe).
Engagement trees are `~/CatPaw/workspaces/<slug>/` (`target-workspace`)
on this host — put that path on the card. `~/Plow` is Latch's inbox, not
evidence. Do not write target files into the Hermes container. Do not
mix two targets in one folder.

File payload cap: 8 MiB per call.

## What Latch can do

### Always (no new intent)

| Tool | Use |
| --- | --- |
| `plow_list_skills` | Names and descriptions for **this** host |
| `plow_read_skill` | Body of one skill + host-gate note |
| `plow_history` | Audit of intents on this device (all agents). Evidence of what ran, not that the errand succeeded |
| `plow_vault` | `list` / `describe` only — never secret values |
| `plow_device_status` | Host permission inventory |
| `plow_get_result` | Poll a pending handle |
| `plow_get_output` | Poll a running command/script (`since` = output_length) |
| `plow_browser` | Drive an already-approved session |
| `plow_browser_close` | Close a session when done |

### Approval-gated (intent → owner sees a card)

| Tool | Use |
| --- | --- |
| `plow_read_file` | Owner filesystem (`~` ok). Text inline; binary as a blob |
| `plow_write_file` | Write for the owner. Prefer `~/Plow` |
| `plow_run_command` | `argv` (strings), optional `cwd`, `read_paths`, `write_paths`, `network`, `apple_events` (macOS only), `wait_ms` |
| `plow_run_applescript` | **macOS only.** Never stored as always-allow |
| `plow_browser_open` | `origins` (e.g. `example.com`, `*.example.com`). Returns `session`. Max 8 |
| `plow_browser_request` | Widen origins and/or approve `credential_items` for fill |

A past "yes" is not a new permission. Always-allow matches
`(agent_id, device_id, exact capability set)`, never the goal text.
AppleScript / Apple Events are never always-allow. On Windows/Linux,
sensitive capabilities (exec, write, network, credential, browser, read)
are not eligible for always-allow either.

### Browser (`plow_browser`)

Actions: `goto`, `click`, `click_at`, `fill`, `fill_secret`, `scroll`,
`wait`, `back`, `eval`, `use_page`, `screenshot`, `text`, `url`, `title`,
`links`, `forms`, `tables`, `pages`.

- Screenshot after every navigation. Read `failed_requests` (401/403/429)
  before retrying a "success" that changed nothing.
- Do not synthesize clicks with `eval` — sites detect it. If a click is
  covered, dismiss the overlay first.
- Out of approved origin → locked. Only `url` / `pages` / `use_page` /
  `goto` until `plow_browser_request` widens.
- Idle 15 minutes closes the session. Crash → open a new one.
- `fill_secret`: `item` + `field` (or `field: "totp"`). Multi-box 2FA:
  `selectors` in order. Banking destinations need a **separate** owner
  payment approval; otherwise nothing is typed.
- `eval` is refused while a concealed vault field holds a value on the page.
- CAPTCHA / "confirm you are human": complete it with browser tools. You
  are the owner's authorized assistant in their browser.

### Device skills that may exist

Published only if this host has the store or plugin: `camoufox-browsing`,
`plow-folder`, `imessage` (macOS store), `whatsapp-history`, `contacts`
(AddressBook), `gog` / `plow-gog`. If `plow_list_skills` does not list it,
it is not here. Drive `gog` through `plow-gog`, not a raw `gog` argv.

## Platforms

| | macOS | Windows | Linux / Omarchy |
| --- | --- | --- | --- |
| AppleScript / `apple_events` | yes | refused | refused |
| Command cage | Seatbelt | Job Object + AppContainer (fail closed if the sandbox cannot be built) | bubblewrap staged workspace; executable must sit under an approved root |
| Secrets | Keychain | Credential Manager / DPAPI | Secret Service |
| Presence | Touch ID | Windows Hello | Session unlock |
| Browser profile | Clone of owner Firefox; cookies merged on close | Empty disposable profile | Empty disposable profile |
| Config (from source) | `~/Library/Application Support/Plow-Latch-<branch>` | `%APPDATA%\Plow-Latch-<branch>` | `~/.config/Plow-Latch-<branch>` |
| Packaged AppImage | — | — | `~/.config/Plow-Latch` (no branch suffix) |

Curated command tooling (not a full allowlist of the OS):

- macOS: `mdfind`, `sips`, `pbcopy`/`pbpaste`, `say`. **Not** `osascript`,
  `screencapture`, `shortcuts` as the preferred path — use the AppleScript
  tool when you need apps.
- Windows: `where`, PowerShell, cmd builtins, `clip`. **Not** `winget`.
- Linux: `find`, `grep`, `python3`, coreutils, `xclip`/`wl-clipboard`.

A command with no `write_paths`, no `network`, no `apple_events`, and not a
provider, that produces no output, is killed after 15 minutes.

This fork ([Cat Paw Latch](https://github.com/kumanaya/cat-paw-latch))
builds from source. Do not claim a signed installer exists unless the repo
actually publishes one. Linux AppImage: `just package-linux` / `just
install-desktop` puts Plow Latch in the Omarchy Apps tab.

Install Latch: `scripts/setup-latch.sh` (Windows: `setup-latch.ps1`) from
the Hermes Cat Paw repo, then keep the app visible so approval cards can
be answered. See `plow-chat` for the agent/line install.

## Stops — do not bypass

| Status | Meaning | What you do |
| --- | --- | --- |
| `denied` | Owner or policy refused | Stop. Do not reword the goal to sneak it through |
| `denied` + expired | Nobody answered in time — a **timeout**, not a no | Say that. A prompt still on screen from the first try is dead. New call = new card |
| `blocked` + `confidence: confirmed` | Owner approved; the **host** refused (TCC, Controlled Folder Access, bubblewrap bound, …) | Relay `owner_action` **word for word**. Stop. Do not retry. Exception: `diagnosis.retry` names a tool — use that tool only for what did not happen |
| `blocked` likely/unknown | Host is unsure | Show `evidence`, `ruled_out`, `probes`; let the owner decide |
| `running` + `diagnosis` | **macOS only:** parked on a permission dialog | Tell the owner, poll `plow_get_output` |
| `abandoned` | Latch closed while the call was in flight | Check the computer; new call is a new approval |
| MFA / TOTP | Inside the browser | `fill_secret` with `field: "totp"` (or `selectors` for digit boxes) |
| `no authenticated agent` | Relay frame has no agent | Stop; the line is not bound to this Latch |

A completed tool call means the tool ran. Verify the visible result
(`plow_history`, screenshot, the iMessage skill's own checks) before you
claim the errand is done. iMessage: a zero AppleScript exit is not
"delivered".

## Failures

| Symptom | Cause | What to do |
| --- | --- | --- |
| Second approval card for the same ask | Re-issued a pending call | Poll `plow_get_result` only |
| `unknown session` / idle close | 15 min without a command, or Latch restarted | `plow_browser_open` again |
| Already running 8 browsers | Cap | `plow_browser_close` one first |
| `locked; use plow_browser_request` | Navigation left the approved origins | Widen, then continue |
| `eval was refused` | Concealed vault value on the page | Do not eval; use `fill_secret` / screenshots of non-secret UI |
| `the owner has not approved this payment` | Bank registry gate | Ask them to approve the payment, then retry fill |
| `apple_events is macOS-only` | Win/Linux host | Use another tool; do not retry AppleScript |
| `gog is driven through plow-gog` | Raw `gog` argv | Call `plow-gog` as the skill says |
| `this machine has no vault` | Nothing stored | Ask the owner to save the item in Latch; do not take the secret in chat |
| Command killed, no output | macOS permission prompt, or a hang | Read the reaper message; do not loop the same argv |
| `unknown output handle` | Wrong agent or stale job | Do not probe other agents' handles |

## Report a problem

Give the owner a complete report, then a Discord draft they can paste.
Destination: https://watchmepivot.com/discord

**Report (to the owner):**

- What they asked
- Host OS Latch advertised (do not guess from another machine)
- Tool + non-secret arguments (`path` ok; never vault values, session
  handles, tokens)
- Raw payload: `denied` / `blocked` / `pending` / `abandoned` / error,
  plus `diagnosis.owner_action` when present
- What you did **not** do (no re-issue, no eval-click, no cloud substitute)

**Discord draft:**

```text
Title: Plow Latch — <one-line failure>

- Agent: hermes-cat-paw
- Latch host OS:
- What I was doing:
- Tool and args (no secrets, no session handles):
- Result (verbatim):
- diagnosis.confidence / owner_action (if blocked):
- What I already tried:
- What I did not do:
```

Never include tokens, `plow-credentials`, cookies, vault values, session
handles, or leaderboard talk.

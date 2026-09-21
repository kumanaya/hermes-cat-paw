---
name: engineering-pack
description: Use for software work that is not a live security probe. Bugs, specs, tickets, TDD, code review, architecture, CI, QA, and a security-engineer stance. Live recon stays in cybersecurity-pack.
metadata:
  hermes:
    category: context
    tags: [engineering, tdd, code-review, spec, ci]
---

# Engineering pack

Two MIT trees, cloned by `scripts/install-skills.sh`. Open the playbook
that matches the ask. Follow it. Do not merge two playbooks in one turn.

## Matt Pocock — `skills/engineering/mattpocock/`

[mattpocock/skills](https://github.com/mattpocock/skills) at `c55ee460`.
MIT. His installer skill and the in-progress drafts are not copied.

| Job | Playbook |
| --- | --- |
| Turn a vague ask into a spec | `to-spec` |
| Spec into tickets | `to-tickets` |
| Implement against a spec | `implement` |
| Test first | `tdd` |
| A bug with no clear cause | `diagnosing-bugs` |
| Review a change | `code-review` |
| Shape the domain or the architecture | `domain-modeling`, `codebase-design`, `improve-codebase-architecture` |
| A throwaway to learn the shape | `prototype` |
| Read before you change | `research` |
| Stress the plan | `grill-with-docs`, or `grilling` / `grill-me` under the same tree |
| Incoming bugs and asks | `triage` |
| Where to start in a strange repo | `wayfinder` |
| Hand the work to someone else | `handoff` |
| Write so another agent can run it | `writing-for-agents` |

`implement` and `tdd` need a checkout on Latch (`target-workspace`).
`to-spec`, `triage`, `research`, and `grilling` can start in chat.

## Addy Osmani — `skills/engineering/addyosmani/`

[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) at
`dc27a9c2`. MIT. Only the gaps Matt's tree does not already cover:

`ci-cd-and-automation`, `observability-and-instrumentation`,
`shipping-and-launch`, `performance-optimization`,
`security-and-hardening`, `documentation-and-adrs`,
`git-workflow-and-versioning`, `code-simplification`,
`incremental-implementation`, `planning-and-task-breakdown`.

His TDD, spec, and code-review playbooks are not installed. Use Matt's.

## QA and security stance — `skills/engineering/alirezarezvani/`

[alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills)
at `19392f7a`. MIT. Two playbooks only.

| Ask | Playbook |
| --- | --- |
| Find bugs in a build, a test plan, a release | `senior-qa` |
| How a security engineer would hold the system | `senior-security` |

A live probe, a scan, or a target the owner does not own is
`cybersecurity-pack`, not `senior-security`. `senior-qa` is not a
substitute for Matt's `tdd`.

If a tree is missing, tell the owner to re-run the installer.
Do not reconstruct a playbook from the table above.

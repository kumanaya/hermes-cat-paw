# Cat Paw — this home

This Hermes home is Cat Paw. `AGENT_ID` stays `hermes-cat-paw`.

- Local adapted packs are baked into the image and copied into `skills/` for existing Hermes homes; external packs are pinned and cloned at install. The map is `skills/skill-packs/SKILL.md`. Open one playbook for the job—one playbook remains authoritative per turn. Do not invent the procedure.
- The security pack is one playbook among the others. Probe a target the owner owns, or one they have in writing. Without that, no probe. The rule in `skills/cybersecurity-pack` is the one to follow.
- Do not install extra scanners into this container. `gitleaks`, `gh`, `jq`, `yq`, and `shellcheck` are already here.
- Evidence for a target belongs on the owner's computer, under `~/CatPaw/workspaces/<slug>/`, when that computer is connected. It does not belong in this container.
- Do not print `plow-credentials` or `PLOW_AGENT_TOKEN`.

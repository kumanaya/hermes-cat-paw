# Lightweight Plow Chat configuration over the official Hermes base image.
# Base: plow-cloud-agents:base-<full commit sha> — one immutable tag per commit
# from the plow-pbc/plow image build, no `latest`. This pin is ef001937, and
# the digest below is the manifest the public registry serves for that tag.
# Ref: https://github.com/plow-pbc/plow-hermes-agent#building-a-variant-image
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-67021a7029e33e80bcb27899be6515a5a0e9b37b@sha256:0c3892e93c1a001c61fb7106396e0a4b7e0219008184fd90719caa84a3390ff0

# Usage reporting is the base's own Agent Index reporter (pinned client + s6
# `agent-index` service). It reads AGENT_ID; the Plow cloud passes no
# environment, so the id is baked here. Compose sets the same value.
ENV AGENT_ID=hermes-cat-paw

# Tiny review CLIs (gitleaks, gh, jq, yq, shellcheck). No Semgrep/Trivy/
# nmap — those bloat the image. Live probes stay on Latch. External playbooks
# clone at install time; local adapted packs are baked or copied.
COPY vendor/review-tools.pin /opt/cat-paw/review-tools.pin
COPY image/install-review-tools.sh image/verify-review-tools.sh /opt/cat-paw/
RUN chmod 0755 /opt/cat-paw/install-review-tools.sh /opt/cat-paw/verify-review-tools.sh \
 && /opt/cat-paw/install-review-tools.sh \
 && /opt/cat-paw/verify-review-tools.sh

# ── the playbooks ─────────────────────────────────────────────────────────────
# Two sources. First the shared ones, from cat-paw-workflows at the commit
# pinned in vendor/cat-paw-workflows.pin — the same commit openclaw-cat-paw
# pins, so a fix to a playbook lands in both agents.
#
# The Dockerfile reads sha= out of that file rather than taking an ARG, so the
# pin and the build cannot drift: one place to bump, no way to disagree.
#
# `--filter=blob:none` with a full clone, not --depth 1: the pin is a commit
# and a shallow clone cannot reach one that is not a branch tip. The resolved
# HEAD is compared against the pin before anything is copied, and the clone is
# removed in the layer it was made in.
ARG CAT_PAW_WORKFLOWS_PIN=vendor/cat-paw-workflows.pin
COPY vendor/cat-paw-workflows.pin ${CAT_PAW_WORKFLOWS_PIN}
RUN set -eu; \
    pin="${CAT_PAW_WORKFLOWS_PIN}"; \
    repo="$(sed -n 's/^repo=//p' "$pin")"; \
    sha="$(sed -n 's/^sha=//p' "$pin")"; \
    [ -n "$repo" ] && [ -n "$sha" ] || { echo "cat-paw-workflows: malformed $pin" >&2; exit 1; }; \
    git clone --filter=blob:none "$repo" /tmp/cat-paw-workflows; \
    git -C /tmp/cat-paw-workflows checkout --quiet "$sha"; \
    got="$(git -C /tmp/cat-paw-workflows rev-parse HEAD)"; \
    [ "$got" = "$sha" ] || { echo "cat-paw-workflows: wanted $sha, got $got" >&2; exit 1; }; \
    mkdir -p /var/lib/hermes/skills /opt/hermes/skills; \
    cp -a /tmp/cat-paw-workflows/skills/. /var/lib/hermes/skills/; \
    cp -a /tmp/cat-paw-workflows/skills/. /opt/hermes/skills/; \
    rm -rf /tmp/cat-paw-workflows; \
    chown -R 10000:10000 /var/lib/hermes/skills /opt/hermes/skills

# Then the five skills that are statements about THIS agent: the boot, the
# state directory, how a reply is delivered, what is baked in this image. They
# cannot be shared, because the same text would be false in the other runtime.
#
# No flattening step here, and deliberately: the Hermes loader walks nested
# skills, so `skills/<pack>/<playbook>/SKILL.md` loads as written. The
# OpenClaw image has to lift them, and that is a difference between the runtimes
# rather than something to fix in the playbooks.
COPY --chown=10000:10000 skills/ /var/lib/hermes/skills/
COPY --chown=10000:10000 skills/ /opt/hermes/skills/
COPY --chown=10000:10000 LICENSE /var/lib/hermes/skills/LICENSE.hermes-cat-paw
COPY --chown=10000:10000 LICENSE /opt/hermes/skills/LICENSE.hermes-cat-paw

# The pin that produced these playbooks, left in the image beside them. When
# an owner asks "which version of the playbooks is this?", the answer should
# be readable off the machine rather than reconstructed from a build log.
COPY --chown=10000:10000 vendor/cat-paw-workflows.pin /opt/hermes/skills/cat-paw-workflows.pin

# Normaliza modos sem mexer no dono do root de skills (que é da base).
RUN find /opt/hermes/skills -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills -type f -exec chmod 0644 {} + \
 && find /var/lib/hermes/skills -type d -exec chmod 0755 {} + \
 && find /var/lib/hermes/skills -type f -exec chmod 0644 {} +

# Identity specific to this agent. plow-init writes $HERMES_HOME/SOUL.md on
# every boot as the base persona plus /opt/hermes/plow-seed/persona.md.
# The source file is PERSONA.md. The destination stays lowercase: that is the
# path plow-init opens. Do not COPY a SOUL.md into the home: the volume hides
# the image layer, and the next boot overwrites it.
COPY PERSONA.md /opt/hermes/plow-seed/persona.md
RUN chmod 0644 /opt/hermes/plow-seed/persona.md

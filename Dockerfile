# Lightweight Plow Chat configuration over the official Hermes base image.
# Base: plow-cloud-agents:base-<full commit sha> — one immutable tag per commit
# from the plow-pbc/plow image build, no `latest`. This pin is ef001937, and
# the digest below is the manifest the public registry serves for that tag.
# Ref: https://github.com/plow-pbc/plow-hermes-agent#building-a-variant-image
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-ef0019372ff8bca593611b31ebd2e08f9f1458ff@sha256:a8a2f97ad78b8192d80a984dce81d3bf5a9a883d18cb7b677704913a09b56aee

# Usage reporting is the base's own Agent Index reporter (pinned client + s6
# `agent-index` service). It reads AGENT_ID; the Plow cloud passes no
# environment, so the id is baked here. Compose sets the same value.
ENV AGENT_ID=hermes-cat-paw

# Tiny review CLIs (gitleaks, gh, jq, yq, shellcheck). No Semgrep/Trivy/
# nmap — those bloat the image. Live probes stay on Latch. Playbooks clone
# at install time.
COPY vendor/review-tools.pin /opt/cat-paw/review-tools.pin
COPY image/install-review-tools.sh image/verify-review-tools.sh /opt/cat-paw/
RUN chmod 0755 /opt/cat-paw/install-review-tools.sh /opt/cat-paw/verify-review-tools.sh \
 && /opt/cat-paw/install-review-tools.sh \
 && /opt/cat-paw/verify-review-tools.sh

# Hermes Cat Paw overlays product skills (Plow Chat, Plow Latch, cybersecurity
# pack routing, change-review, target-workspace, image-tools).
COPY --chown=10000:10000 skills/ /var/lib/hermes/skills/
COPY --chown=10000:10000 skills/ /opt/hermes/skills/

# Normaliza modos sem mexer no dono do root de skills (que é da base).
RUN find /opt/hermes/skills -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills -type f -exec chmod 0644 {} + \
 && find /var/lib/hermes/skills -type d -exec chmod 0755 {} + \
 && find /var/lib/hermes/skills -type f -exec chmod 0644 {} +

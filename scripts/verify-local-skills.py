from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
EXPECTED_PACKS = {
    "software-delivery-pack": (
        "parallel-investigation-dag",
        "skill-definition-pressure-test",
        "software-architecture-decision-gate",
    ),
    "minimal-code-pack": (
        "dependency-abstraction-removal-audit",
        "feature-necessity-decision",
        "technical-shortcut-debt-ledger",
    ),
    "token-efficient-agenting-pack": (
        "agent-instruction-compression-safety-test",
        "llm-callsite-inventory-and-labeling",
        "reversible-agent-context-migration",
    ),
    "action-first-communication-pack": (
        "low-cognitive-load-runbook",
        "one-screen-incident-status-update",
        "stalled-task-next-action-reset",
    ),
    "code-graph-pack": (
        "code-change-blast-radius-map",
        "cross-layer-feature-trace",
        "repository-architecture-graph",
    ),
    "codebase-knowledge-pack": (
        "business-domain-knowledge-map",
        "codebase-onboarding-tour",
        "evidence-linked-codebase-question-map",
    ),
    "recent-research-pack": (
        "community-claim-sentiment-pulse",
        "thirty-day-competitor-momentum-scan",
        "thirty-day-cross-source-signal-brief",
    ),
    "agent-skill-catalog-pack": (
        "agent-skill-catalog-discovery",
        "agent-skill-provenance-license-review",
        "minimal-agent-skill-stack-selection",
    ),
    "scientific-research-pack": (
        "preregistered-study-power-plan",
        "reproducible-scientific-compute-plan",
        "scientific-result-claim-calibration",
    ),
    "diagram-design-pack": (
        "release-migration-rollback-sequence-diagram",
        "user-journey-lifecycle-state-map",
        "website-architecture-trust-boundary-diagram",
    ),
}

REQUIRED_BOUNDARY_ROUTERS = ("target-workspace", "plow-latch")

PRECEDENCE_MARKERS = (
    "cybersecurity and change-review first",
    "exact named child outcome beats broad category rows",
    "provenance/source/license review wins over generic skill pressure-testing",
    "architecture decision planning wins over generic engineering architecture",
    "feature-need validation wins over generic product ideation",
    "bounded 30-day public/community signal wins over generic competitor/research",
    "open exactly one child playbook",
)


def read_frontmatter(path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("missing frontmatter")
    end = None
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            end = index
            break
    if end is None:
        raise ValueError("unterminated frontmatter")
    name = None
    category = None
    in_metadata = False
    in_hermes = False
    for line in lines[1:end]:
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        key, separator, value = line.partition(":")
        if not separator:
            continue
        key = key.strip()
        value = value.strip().strip("\"'")
        if indent == 0:
            in_metadata = key == "metadata" and not value
            in_hermes = False
            if key == "name":
                name = value
        elif in_metadata and indent == 2 and key == "hermes":
            in_hermes = not value
        elif in_metadata and in_hermes and indent == 4 and key == "category":
            category = value
    if not name:
        raise ValueError("missing frontmatter name")
    if category != "context":
        raise ValueError("metadata.hermes.category must be context")
    return name


def pin_router_counts(path):
    counts = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split(None, 1)
        if len(fields) == 2 and fields[0] == "router":
            name = fields[1].strip()
            counts[name] = counts.get(name, 0) + 1
    return counts


def main():
    errors = []
    expected_children = sum(len(children) for children in EXPECTED_PACKS.values())
    if len(EXPECTED_PACKS) != 10 or expected_children != 30:
        errors.append("the verifier must define exactly 10 packs and 30 children")

    adapted = set()
    for child in SKILLS.iterdir() if SKILLS.is_dir() else ():
        if not child.is_dir():
            continue
        router = child / "SKILL.md"
        if not router.is_file():
            continue
        try:
            if "local Cat Paw adaptation" in router.read_text(encoding="utf-8"):
                adapted.add(child.name)
        except (OSError, UnicodeError):
            continue
    if adapted != set(EXPECTED_PACKS):
        missing = sorted(set(EXPECTED_PACKS) - adapted)
        extra = sorted(adapted - set(EXPECTED_PACKS))
        if missing:
            errors.append("missing adapted pack roots: " + ", ".join(missing))
        if extra:
            errors.append("unexpected adapted pack roots: " + ", ".join(extra))

    for pack, children in EXPECTED_PACKS.items():
        root = SKILLS / pack
        if not root.is_dir():
            errors.append(f"missing adapted pack directory: {pack}")
            continue
        expected_files = {"SKILL.md"}
        expected_files.update(f"{child}/SKILL.md" for child in children)
        actual_files = set()
        try:
            for path in root.rglob("SKILL.md"):
                if path.is_file():
                    actual_files.add(path.relative_to(root).as_posix())
        except OSError as exc:
            errors.append(f"{pack}: cannot enumerate SKILL.md files: {exc}")
        if actual_files != expected_files:
            missing = sorted(expected_files - actual_files)
            extra = sorted(actual_files - expected_files)
            if missing:
                errors.append(f"{pack}: missing SKILL.md files: {', '.join(missing)}")
            if extra:
                errors.append(f"{pack}: unexpected SKILL.md files: {', '.join(extra)}")
        for relative in sorted(expected_files & actual_files):
            path = root / relative
            directory_name = pack if relative == "SKILL.md" else relative.rsplit("/", 1)[0]
            try:
                actual_name = read_frontmatter(path)
            except (OSError, UnicodeError, ValueError) as exc:
                errors.append(f"{path}: {exc}")
                continue
            if actual_name != directory_name:
                errors.append(f"{path}: frontmatter name {actual_name!r} does not match {directory_name!r}")

    pin = ROOT / "vendor" / "skill-packs.pin"
    try:
        router_counts = pin_router_counts(pin)
    except (OSError, UnicodeError) as exc:
        errors.append(f"{pin}: cannot read pin: {exc}")
        router_counts = {}
    for pack in EXPECTED_PACKS:
        if router_counts.get(pack, 0) != 1:
            errors.append(f"{pack}: expected exactly one router entry in {pin.name}, found {router_counts.get(pack, 0)}")
    for router in REQUIRED_BOUNDARY_ROUTERS:
        if router_counts.get(router, 0) != 1:
            errors.append(f"{router}: expected exactly one boundary router entry in {pin.name}, found {router_counts.get(router, 0)}")

    catalog = SKILLS / "skill-packs" / "SKILL.md"
    try:
        catalog_text = catalog.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        errors.append(f"{catalog}: cannot read router map: {exc}")
        catalog_text = ""
    normalized_catalog = " ".join(catalog_text.split()).lower()
    for marker in PRECEDENCE_MARKERS:
        if marker not in normalized_catalog:
            errors.append(f"skills/skill-packs/SKILL.md: missing precedence rule: {marker}")
    for pack in EXPECTED_PACKS:
        if f"`{pack}`" not in catalog_text:
            errors.append(f"{pack}: router is not named in skills/skill-packs/SKILL.md")

    if errors:
        for error in errors:
            print(f"verify-local-skills: {error}", file=sys.stderr)
        return 1
    print("verify-local-skills: 10 adapted packs, 30 children, and 40 SKILL.md files verified")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

"""Check the five skills this repository owns.

The 51 shared playbooks live in
https://github.com/kumanaya/cat-paw-workflows and are verified there, at the
commit this image pins. What is left here are the skills that are statements
about THIS agent — the boot, the state directory, how a reply is delivered,
what is baked in this image — and they are the ones a shared repository cannot
hold, because the same text would be false in the other runtime.

So this file is small on purpose. It proves three things:

  1. exactly the five are here, and nothing crept back in
  2. each one is loadable by OpenClaw: a directory named after its frontmatter
  3. each one actually names this runtime, which is the whole reason it is
     local - a skill that stopped saying "Hermes" stopped earning its place
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"

# The five, and the runtime fact each one has to carry. A skill that names
# neither OpenClaw nor its state directory has drifted back towards the shared
# set, and the honest fix is to move it there, not to let it rot here.
LOCAL_SKILLS = {
    "plow-chat": (r"\bhermes\b", r"/var/lib/hermes"),
    "plow-latch": (r"\bhermes\b", None),
    "target-workspace": (r"\bhermes\b", r"/var/lib/hermes"),
    "image-tools": (r"\bhermes\b", None),
    "skill-packs": (r"\bhermes\b", None),
}

# The other runtime. If one of these lands here it is a port that was pasted
# the wrong way round, and it would be true in this image and false in the
# other one.
FORBIDDEN = re.compile(r"\bopenclaw\b", re.IGNORECASE)


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
            if key == "name":
                name = value
        elif in_metadata and indent == 2 and key == "category":
            category = value
    if not name:
        raise ValueError("missing frontmatter name")
    if category != "context":
        raise ValueError("metadata.category must be context")
    return name


def main():
    errors = []

    if not SKILLS.is_dir():
        print(f"verify-local-skills: no skills directory at {SKILLS}", file=sys.stderr)
        return 1

    actual = {child.name for child in SKILLS.iterdir() if child.is_dir()}
    expected = set(LOCAL_SKILLS)
    if actual != expected:
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        if missing:
            errors.append("missing local skills: " + ", ".join(missing))
        if extra:
            errors.append(
                "skills here that belong in cat-paw-workflows: " + ", ".join(extra)
            )

    total = 0
    for name, (needs_runtime, needs_state_dir) in sorted(LOCAL_SKILLS.items()):
        path = SKILLS / name / "SKILL.md"
        if not path.is_file():
            errors.append(f"missing local skill: skills/{name}/SKILL.md")
            continue
        total += 1
        try:
            frontmatter_name = read_frontmatter(path)
        except (OSError, UnicodeError, ValueError) as exc:
            errors.append(f"{path}: {exc}")
            continue
        if frontmatter_name != name:
            errors.append(
                f"{path}: frontmatter name {frontmatter_name!r} does not match the directory"
            )
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as exc:
            errors.append(f"{path}: cannot read: {exc}")
            continue
        if not re.search(needs_runtime, text, re.IGNORECASE):
            errors.append(
                f"skills/{name}/SKILL.md: names no runtime. A local skill earns its place by "
                "describing this agent; if it does not, it belongs in cat-paw-workflows."
            )
        if needs_state_dir and not re.search(needs_state_dir, text):
            errors.append(
                f"skills/{name}/SKILL.md: does not mention {needs_state_dir}. That path is the "
                "one this agent actually uses; a stale one sends the model to the wrong place."
            )
        found = FORBIDDEN.search(text)
        if found:
            line = text[: found.start()].count("\n") + 1
            errors.append(
                f"skills/{name}/SKILL.md:{line}: names the other runtime ({found.group(0)!r}). "
                "This is the Hermes agent."
            )

    pin = ROOT / "vendor" / "cat-paw-workflows.pin"
    try:
        lines = pin.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError) as exc:
        errors.append(f"{pin}: cannot read pin: {exc}")
        lines = []
    sha = next((l[4:] for l in lines if l.startswith("sha=")), "")
    repo = next((l[5:] for l in lines if l.startswith("repo=")), "")
    if not repo or not sha:
        errors.append(f"{pin}: needs both a repo= and a sha= line")
    elif len(sha) != 40 or not re.fullmatch(r"[0-9a-f]{40}", sha):
        errors.append(f"{pin}: sha must be a full 40-character commit, got {sha!r}")

    if errors:
        for error in errors:
            print(f"verify-local-skills: {error}", file=sys.stderr)
        return 1
    print(
        f"verify-local-skills: {total} runtime-specific skills verified, and "
        f"the shared playbooks are pinned at {sha[:12]}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

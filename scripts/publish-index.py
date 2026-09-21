#!/usr/bin/env python3
"""Publish the Cat Paw page and its use-case stories to the Agent Index.

Requires PLOW_AGENT_TOKEN. --register updates the public page and mints this
install's report key into HERMES_HOME. --story uses that key, not the Plow
token. Point HERMES_HOME somewhere you intend to keep if this machine should
remain an install of hermes-cat-paw.

    AGENT_INDEX_CLIENT=path/to/agent_index_client.py python3 scripts/publish-index.py
"""
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORIES = ROOT / "docs" / "agent-index" / "stories.json"
CLIENT = Path(os.environ.get("AGENT_INDEX_CLIENT", ""))
AGENT = "hermes-cat-paw"
RETIRE = ("omarchy-usage-security", "windows-availability-security")
IMAGES = (
    "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/agent-index/hackathon-banner.png",
    "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/agent-index/hackathon-cat-paw-latch.png",
)


def public_url(url):
    """Swap the main raw prefix when the gallery commit is not on main yet."""
    root = os.environ.get("AGENT_INDEX_RAW_ROOT", "").rstrip("/")
    marker = "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main"
    if root and url.startswith(marker):
        return root + url[len(marker):]
    return url


def run(args, required=True):
    print("+", " ".join(args[:4]), "...")
    completed = subprocess.run([sys.executable, str(CLIENT), *args])
    if completed.returncode != 0 and required:
        sys.exit(completed.returncode)
    return completed.returncode


def main():
    if not CLIENT.is_file():
        sys.exit("Set AGENT_INDEX_CLIENT to agent_index_client.py")
    if not os.environ.get("PLOW_AGENT_TOKEN"):
        sys.exit("no PLOW_AGENT_TOKEN")
    run([
        "--register", "--agent", AGENT,
        "--name", "Hermes Cat Paw",
        "--blurb", "Text the cat. It picks a playbook and does the job.",
        "--runtime", "Hermes / Plow Chat",
        "--repo", "https://github.com/kumanaya/hermes-cat-paw",
        "--install-url", "https://github.com/kumanaya/hermes-cat-paw/blob/main/docs/INSTALL.md",
        "--video", "KjWFtHh0EFE",
        "--image", public_url(IMAGES[0]),
        "--image", public_url(IMAGES[1]),
    ])
    for story_id in RETIRE:
        run(["--agent", AGENT, "--delete-story", story_id], required=False)
    for story in json.loads(STORIES.read_text(encoding="utf-8")):
        args = [
            "--agent", AGENT,
            "--story", story["id"],
            "--title", story["title"],
            "--body", story["body"],
            "--tag", story["tag"],
        ]
        for url in story.get("images") or []:
            args.extend(["--image", public_url(url)])
        run(args)


if __name__ == "__main__":
    main()

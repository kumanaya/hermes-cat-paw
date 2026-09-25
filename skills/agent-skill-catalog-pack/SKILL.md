---
name: agent-skill-catalog-pack
description: "Routes skill discovery, minimal stack selection, and provenance review to one catalog-grounded Cat Paw playbook per turn."
metadata:
  hermes:
    category: context
    tags: [agent-skills, catalog, provenance, licenses, selection, cat-paw]
---

# Agent skill catalog pack

This is a local Cat Paw adaptation of concepts audited in [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills) at the exact audited commit `7b534bc15d833baf3bc98b3ca4fb23eda48342bb`. The source root is MIT licensed, its documentation is CC-BY-4.0, and imported skills retain their own licenses. The license caveat is that this pack does not copy or bulk-import the catalog, does not make a legal conclusion about any item, and records the exact source, revision, and license for each selected skill. This is a local adaptation.

Read this router and choose exactly one child. A catalog is a map, not a license to install everything.

| Request | One child playbook |
| --- | --- |
| Find relevant catalog entries without importing them | `agent-skill-catalog-discovery` |
| Choose the smallest useful skill stack | `minimal-agent-skill-stack-selection` |
| Verify the provenance and license of one selected item | `agent-skill-provenance-license-review` |

## Selection and device boundary

No full catalog installation, AAS Core installation, bulk import, auto-update, package execution, or legal conclusion is allowed. Select and review one playbook at a time. For every selected item, capture its source repository or catalog path, exact revision, license notice, and scope caveat before considering use.

A private repository or artifact requires `target-workspace` and `plow-latch`; keep it on the owner's computer under `~/CatPaw/workspaces/<slug>/`. The Hermes container may hold reasoning but not private target evidence. Do not install, commit, push, merge, or execute an imported skill as part of discovery or review. If provenance is incomplete, leave the item unselected.

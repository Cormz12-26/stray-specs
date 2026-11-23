# 02 — Project structure

**Purpose:** Locate project components and decide where future code and documentation belong.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Observed tree

```text
stray-ecosystem/
  AGENTS.md
  handoff.md
  stray-api/
    AGENTS.md
  stray-android/
    AGENTS.md
  stray-web/
    AGENTS.md
  stray-specs/
    AGENTS.md
    business-logic-v1.0.md
    git-guidelines.md
    sense-making.md
    skills/                 # this knowledge set
```

The three app directories currently contain only their instruction file; each has its own empty Git repository. The specs directory also has its own empty repository. No source tree, build files, tests, CI files, or manifests were present.

## Placement rules

- Put API implementation in `stray-api`, Android implementation in `stray-android`, and web implementation in `stray-web` only after confirming each project's actual scaffold and local instructions.
- Keep ecosystem requirements and engineering knowledge in `stray-specs`; this handoff explicitly places reusable skills in `stray-specs/skills/`.
- Do not invent subdirectory names or move files based on this provisional tree. Follow the framework's established layout when code is added.

## Naming

The repository names use `stray-api`, `stray-android`, `stray-web`, and `stray-specs`. No source-file, symbol, package, or resource naming convention can be inferred from the current snapshot.

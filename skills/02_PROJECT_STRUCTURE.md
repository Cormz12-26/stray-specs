# 02 — Project structure

**Purpose:** Locate project components and decide where future code and documentation belong.

**Confidence note:** Verified against the current working tree and specs baseline commit `47660a2` on 2026-11-23. The code wins (see 16).

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
    business-logic-v1.1-proposed.md
    db-design-choices.md
    db-schema/
      v1.0.0.sql
    git-guidelines.md
    sense-making.md
    skills/                 # this knowledge set
```

Each product/specs directory has its own `main` branch and an initial documentation commit. The three app directories contain only `AGENTS.md`; no application source, build files, tests, CI files, or manifests were present. The v1.1 business logic and v1.0.0 SQL are proposals, not deployed implementation.

## Placement rules

- Put API implementation in `stray-api`, Android implementation in `stray-android`, and web implementation in `stray-web` only after confirming each project's actual scaffold and local instructions.
- Keep ecosystem requirements and engineering knowledge in `stray-specs`; this handoff explicitly places reusable skills in `stray-specs/skills/`.
- Keep full Supabase SQL snapshots in `stray-specs/db-schema/` and forward migrations in `stray-specs/db-migrations/`; follow the version rules in `db-design-choices.md` §10.
- Do not invent subdirectory names or move files based on this provisional tree. Follow the framework's established layout when code is added.

## Naming

The repository names use `stray-api`, `stray-android`, `stray-web`, and `stray-specs`. No source-file, symbol, package, or resource naming convention can be inferred from the current snapshot.

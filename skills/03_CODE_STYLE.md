# 03 — Code style

**Purpose:** Record the conventions contributors can rely on and avoid inventing coding rules before source exists.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Verified conventions

- The root and component `AGENTS.md` files give repository descriptions, not formatting or implementation rules.
- `stray-specs/git-guidelines.md` specifies commit subjects as `scope: Imperative summary`: sentence case, no final period, and no more than 50 characters. A body is optional and should explain why, wrapping at 72 characters.
- The Git guideline's product scopes and identity (`code-name-*`, `Code Name`, `CN`) are uncustomized placeholders. Do not copy them as actual Stray commit scopes or release prefixes without a project decision.
- The same guideline says AI agents should not be commit authors. If a commit is later requested, follow that rule; do not create one as part of this documentation task.

## Not established

No language, formatter, linter, error-handling pattern, logging framework, localization convention, test framework, or dependency policy is present. There are no examples from which to establish naming, comments, architecture, or anti-patterns.

## Contributor rule

Before adding implementation, inspect the selected component's scaffold and adopt its actual tooling and patterns. A style rule without a reason and evidence is not project guidance. Record verified recurring conventions here when source exists; see 14 for the evidence-first workflow.

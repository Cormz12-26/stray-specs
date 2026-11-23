# 15 — Known limitations

**Purpose:** Prioritize gaps most likely to surprise implementers, testers, and operators.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Ranked gaps

1. **No implementation baseline:** API, web, and Android repositories have no commits or tracked source in this workspace. Code behavior, builds, and tests cannot be checked.
2. **Requirements are placeholders:** `business-logic-v1.0.md` has unresolved team/project fields, incomplete system requirements, and generic roles/features; it is not an approved acceptance specification.
3. **No integration contract or schema:** Routes, payloads, migrations, policies, client versions, and error semantics are unknown (see 04, 07, 08).
4. **Security/privacy controls are unverified:** Requirements mention Google Sign-In, Data Privacy Act compliance, location protection, retention, aggregation, and resale consent, but no implementation is available (see 09).
5. **No operational evidence:** Deployment, logging, rollback, backups, performance targets, dependencies, and test commands are undocumented (see 05, 10–13).
6. **Generic workflow policy is uncustomized:** `git-guidelines.md` still contains `code-name`, `Code Name`, and `CN` placeholders. Release tags and scope examples must not be copied as Stray identifiers.

## Redesign candidates

Not rankable without implementation. Revisit architecture and data boundaries after obtaining the source baseline, approved requirements, and actual Supabase schema.

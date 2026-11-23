# 15 — Known limitations

**Purpose:** Prioritize gaps most likely to surprise implementers, testers, and operators.

**Confidence note:** Verified against the current working tree and specs baseline commit `47660a2` on 2026-11-23. The code wins (see 16).

## Ranked gaps

1. **No application implementation baseline:** API, web, and Android repositories have initial documentation commits but no application source. Runtime behavior, builds, and tests cannot be checked.
2. **Product decisions remain open:** `business-logic-v1.1-proposed.md` narrows the MVP but still needs approval of pilot city, species, care guidance, retention, location precision, and moderation thresholds.
3. **No implemented integration contract:** A proposed Supabase snapshot exists, but there is no applied schema, SQLite counterpart, API route/DTO contract, sync implementation, or integration test (see 04, 07, 08).
4. **Security/privacy controls are unverified:** The proposal specifies role/RLS and location safeguards, but no deployed implementation or legal review is available (see 09).
5. **No operational evidence:** Deployment, logging, rollback, backups, performance targets, dependencies, and test commands are undocumented (see 05, 10–13).
6. **Generic workflow policy is uncustomized:** `git-guidelines.md` still contains `code-name`, `Code Name`, and `CN` placeholders. Release tags and scope examples must not be copied as Stray identifiers.

## Redesign candidates

Not rankable without implementation. Revisit architecture and data boundaries after obtaining the source baseline, approved requirements, and actual Supabase schema.

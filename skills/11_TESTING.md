# 11 — Testing

**Purpose:** Set honest confidence expectations and capture the test gates described in the specs.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Current coverage

There are no source files, test files, test runner configuration, CI workflows, or runnable test commands. Test coverage is unknown, not zero measured by a coverage tool.

## Written workflow

The Git guideline distinguishes developer unit testing on `main`, QA system testing on `beta`, and independent integration testing against a published bundle on `release`, followed by explicit production approval. This is documented policy only; no evidence shows it is configured or followed.

## When source exists

- Test each changed unit and its validation/error paths.
- Test API ↔ Supabase behavior, authorization, schema compatibility, and both web and Android consumers for contract changes (see 04, 07, 08).
- Include privacy, retention, and location-access cases where approved requirements apply (see 09).
- Test the exact artifact promoted between release gates; record build identity and results.
- Use the project's actual test commands. Do not report a test as passing if no runner or target exists.

Mocking policy, manual drills, supported OS/browser versions, and coverage targets are not specified.

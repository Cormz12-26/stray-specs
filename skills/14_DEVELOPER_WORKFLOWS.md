# 14 — Developer workflows

**Purpose:** Give contributors safe first steps in this workspace and explain why normal build workflows are not yet available.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Setup

No setup instructions, language runtimes, manifests, build tools, or application entry points are present. Do not install dependencies or guess a build command. First obtain or create the approved source baseline for the component and document its prerequisites.

## Inspect a component

1. Read the root `AGENTS.md` and the selected component's `AGENTS.md`.
2. Inspect its actual tree, Git status/history, manifests, entry points, tests, and CI before editing.
3. Confirm whether implementation and remote history are available; do not treat an empty local repository as a clean, complete product.
4. Record any verified architecture or cross-component coupling in 01 and 04.

**Why:** The current folders have no commits or tracked source, so assumed setup and build steps would be misleading (see 06 #1).

## Change an API/client contract

1. Find the route, schema, auth, and both client consumers.
2. Change producer, consumers, validation, and contract tests together.
3. Validate authorization and privacy impact, then follow the actual test gates.

**Why:** The candidate API/Supabase/client boundary is described but no contract is supplied (see 04, 07, 08).

## Refresh these skills

1. Compare guidance to current source and history.
2. Process each inbox item with evidence and credit; merge or mark unverified.
3. Retire stale material rather than deleting it; append principles and update this index.

**Why:** There is no source history yet, so confidence notes must say so instead of implying a release baseline.

For each workflow, add what surprised you to `INBOX.md`.

# 10 — Deployment

**Purpose:** Preserve the written release gates and flag the placeholders and absent deployment evidence.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## What the specs say

`stray-specs/git-guidelines.md` describes a maturity flow: `main` development → `beta` system testing → `release` independent integration testing and candidate approval → production. It requires release tags to identify exact tested commits on `release`, and production approval to be separate. Product prefixes (`WCN`, `BCN`, `ACN`, `SCN`) and identity fields are placeholders, not approved Stray tags.

## What is not verified

No branch, commit, CI pipeline, build command, artifact, environment, host, release credential, deployment procedure, rollback path, or production approval record exists in the supplied repositories. Actual release order across applications is unknown.

## Safe release checklist (policy, not an executable runbook)

1. Confirm the project has adopted and customized the branch, version, and tag policy.
2. Build each actual product with its documented toolchain and retain the exact artifact/commit identity.
3. Run developer/unit checks on `main`, system checks on `beta`, then publish and independently test only the approved `release` bundle.
4. Correct defects, rebuild, and use a new candidate iteration; never move or reuse a tag.
5. Obtain explicit production approval and deploy the exact approved candidate.
6. Document rollback and carry fixes back to ongoing development where applicable.

Do not execute deployment based on this document alone. See 11 for test gates and 14 for repository inspection.

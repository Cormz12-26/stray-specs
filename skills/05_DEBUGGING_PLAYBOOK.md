# 05 — Debugging playbook

**Purpose:** Provide safe first steps for diagnosing failures until runtime logs and source are available.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Observability inventory

No runtime, server, client, database, or CI logs are included. No exact application error messages, error codes, health endpoints, or telemetry locations are known. Do not infer a production symptom from the placeholder business-logic requirements.

## First diagnostic steps

1. Identify the affected product, exact build/commit, environment, request/action, and timestamp. Redact credentials, tokens, personal data, and precise user locations.
2. Capture the full error and relevant request/response metadata without secret values; determine whether the failure occurs in client, API, or Supabase.
3. Check connectivity and the relevant service's own logs/health tools. The applicable commands and log locations must come from the deployed implementation, which is absent here.
4. Reproduce with the smallest safe test case. Avoid production writes or changing access policies while diagnosing.
5. Record a verified cause and fix in 06 only when supported by logs, code, tests, or an incident record.

**Miss →** Without a build identifier and timestamp, logs across client/API/database cannot be correlated; with sensitive payloads, debugging can create a privacy incident.

## Useful repository checks

Run from the ecosystem directory in PowerShell:

```powershell
Get-ChildItem -Force -Recurse
git -C stray-api status --short --branch
git -C stray-web status --short --branch
git -C stray-android status --short --branch
git -C stray-specs status --short --branch
```

These inspect files and repository state; they are not application health checks.

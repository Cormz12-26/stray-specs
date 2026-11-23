# 09 — Security

**Purpose:** Distinguish stated privacy/security requirements from controls actually implemented.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Stated requirements (not implementation evidence)

`stray-specs/business-logic-v1.0.md` mentions Google Sign-In and lists security/privacy by design, Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for data resale. The requirements remain a template with unresolved project details. No control can be claimed as implemented.

## Threat model status

Assets, actors, trust boundaries, auth/session lifecycle, role/authorization model, secrets storage, injection surfaces, debug gates, accepted risks, and incident response are undocumented. The API description implies a client/API/Supabase boundary, but whether clients also access Supabase directly is unknown (see 01).

## Security checklist before release

- Verify sign-in token validation, server-side authorization, account lifecycle, and role assignment separately; Google authentication alone does not establish permission.
- Verify Supabase access policies and least privilege for each path.
- Identify location and other personal data flows; minimize collection, restrict access, set approved retention/deletion rules, and prevent individual-level trails unless explicitly authorized.
- Keep credentials in an approved secret store and refer to environment variable names only in docs; never commit values or log tokens.
- Test boundary validation, access denial, debug/production configuration, and privacy requirements before deployment.
- Obtain appropriate review for Data Privacy Act compliance; the template alone is not legal advice or proof of compliance.

**Miss →** Treating an unimplemented requirement as a control can expose personal or location data and create a false compliance claim. No accepted security gap is verified; see 15.

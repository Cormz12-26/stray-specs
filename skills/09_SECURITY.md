# 09 — Security

**Purpose:** Distinguish stated privacy/security requirements from controls actually implemented.

**Confidence note:** Verified against the current working tree and specs baseline commit `47660a2` on 2026-11-23. The code wins (see 16).

## Stated requirements (not implementation evidence)

`business-logic-v1.1-proposed.md` proposes Google Sign-In, privacy-by-design, Data Privacy Act review, location protection, retention limits, no per-user trails, aggregation thresholds, and no MVP data resale. These are requirements, not proof of implementation.

## Threat model status

The v1.1 proposal and SQL snapshot define a starting role model and table-level RLS policies, but they are not yet approved, deployed, or tested. Runtime token validation, the client/API/Supabase trust boundary, secrets storage, injection surfaces, debug gates, accepted risks, and incident response remain unverified (see 01).

## Security checklist before release

- Verify sign-in token validation, server-side authorization, account lifecycle, and role assignment separately; Google authentication alone does not establish permission.
- Verify Supabase access policies and least privilege for each path.
- Identify location and other personal data flows; minimize collection, restrict access, set approved retention/deletion rules, and prevent individual-level trails unless explicitly authorized.
- Keep credentials in an approved secret store and refer to environment variable names only in docs; never commit values or log tokens.
- Test boundary validation, access denial, debug/production configuration, and privacy requirements before deployment.
- Obtain appropriate review for Data Privacy Act compliance; the proposal is not legal advice or proof of compliance.

**Miss →** Treating an unimplemented requirement as a control can expose personal or location data and create a false compliance claim. No accepted security gap is verified; see 15.

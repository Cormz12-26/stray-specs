# 04 — Change rules

**Purpose:** Identify coordinated changes and required retesting so cross-component updates do not silently drift.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Verifiable lockstep sets

No mirrored constants, enums, registries, column lists, error codes, or types can be inventoried: no source files, schemas, API definitions, or tests are present. Do not treat the following candidates as proven lockstep sets:

| Candidate boundary | Evidence and required confirmation | Miss → |
|---|---|---|
| API ↔ Supabase | API `AGENTS.md` describes communication with Supabase; no table or query definitions exist. | Schema/policy drift may reject requests or expose data; exact behavior is unknown. |
| API ↔ web/Android | API `AGENTS.md` names both clients; no endpoint or DTO contract exists. | A server change may break one or both clients; affected versions cannot be identified. |
| Sign-in ↔ authorization | `business-logic-v1.0.md` lists Google Sign-In as a requirement; there is no role model or token contract. | Authentication may be mistaken for authorization; access behavior is undefined. |

## Change checklist

1. Find the implementation and all consumers, including Supabase policies and shipped client versions; if unavailable, stop short of claiming compatibility.
2. Identify shared fields, enums, errors, and validation rules by searching the actual source and schema.
3. Update producers, consumers, and contract tests together; document migrations and any compatibility window.
4. Test each affected client and the integration boundary. The available test strategy is currently unknown (see 11).
5. Add a verified set here with numbered paths and explicit `Miss →` consequences once evidence exists.

No product-specific incident or hidden coupling could be verified; see 06 #1.

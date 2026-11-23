# 04 — Change rules

**Purpose:** Identify coordinated changes and required retesting so cross-component updates do not silently drift.

**Confidence note:** Verified against the current working tree and specs baseline commit `47660a2` on 2026-11-23. The code wins (see 16).

## Verifiable lockstep sets

No implemented mirrored constants, enums, registries, API contracts, or tests can be inventoried. `db-schema/v1.0.0.sql` defines a proposed server schema, but no local SQLite schema or sync implementation is present. Do not treat the following candidates as proven runtime lockstep sets:

| Candidate boundary | Evidence and required confirmation | Miss → |
|---|---|---|
| API ↔ Supabase | The snapshot defines server tables and policies; API queries, migrations, and deployment are absent. | Schema/policy drift may reject requests or expose data; no integration test currently detects it. |
| Server ↔ local SQLite | The design uses global `uuid` and `*_uuid` links; no client schema or sync code exists. Server `id` must never be copied. | Local relations or sync payloads can break if they use server `id` or diverge in names/types. |
| API ↔ web/Android | API `AGENTS.md` names both clients; no endpoint or DTO contract exists. | A server change may break one or both clients; affected versions cannot be identified. |
| Sign-in ↔ authorization | The v1.1 proposal and SQL snapshot define roles, but no deployed token contract or account provisioning has been verified. | Authentication may be mistaken for authorization; elevated roles may be assigned unsafely. |

## Change checklist

1. Find the implementation and all consumers, including Supabase policies and shipped client versions; if unavailable, stop short of claiming compatibility.
2. Identify shared fields, enums, errors, and validation rules by searching the actual source and schema.
3. Update producers, consumers, and contract tests together; document migrations and any compatibility window.
4. Test each affected client and the integration boundary. The available test strategy is currently unknown (see 11).
5. Keep forward migrations in `db-migrations/` on the patch sequence and exported full snapshots in `db-schema/` on the minor sequence (see `db-design-choices.md` §10).
6. Add a verified runtime set here with numbered paths and explicit `Miss →` consequences once implementation exists.

No product-specific incident or hidden coupling could be verified; see 06 #1.

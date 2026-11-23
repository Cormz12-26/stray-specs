# 07 — Database

**Purpose:** Explain known database boundaries and the evidence required before changing data or migrations.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Known facts

- The API repository description says the backend communicates with the Supabase database API.
- No schema, migrations, policies, seeds, query code, backup configuration, or database credentials/configuration are present.
- `business-logic-v1.0.md` calls for privacy by design, retention limits, location protection, no per-user trails, aggregation thresholds, and consent for data resale. This is an incomplete requirements template, not verified database behavior.

## Unknown and unsafe to assume

Identity keys, foreign keys, table names, deletion semantics, retention schedules, row-level security, indexes, migration tool, backup/restore procedure, and production data are all unknown. No database diagram or table map can be responsibly supplied from this evidence.

## Before a database change

1. Locate the authoritative schema, migrations, and Supabase policies; confirm which environment each applies to.
2. Trace the data through API and clients, including identifiers, location fields, and deletion/retention paths.
3. Define constraints and privacy behavior before migration; test existing and new rows, authorization boundaries, and rollback/restore.
4. Coordinate changes with API and both clients where contracts change (see 04 and 08).

**Miss →** A migration without the real schema or policy context can corrupt data, block clients, or make sensitive rows accessible. No concrete dangerous operation or index strategy is verified yet.

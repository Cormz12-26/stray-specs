# 07 — Database

**Purpose:** Explain the offline-first identity contract and the proposed Supabase schema.

**Confidence note:** Verified against `db-design-choices.md` and `db-schema/v1.0.0.sql` on 2026-11-23. The code wins (see 16); the SQL is a proposal until applied and tested.

## Identity and sync contract

- `uuid` is the global row identity. Relationship columns use the referenced entity plus `_uuid`; syncable server relations intentionally do not declare `REFERENCES`, so offline batches may arrive out of order.
- Server `id bigint GENERATED ALWAYS AS IDENTITY` is a server-only primary/index key, not an ordering cursor. It is not a relationship key and must not enter sync payloads. Client reads use the snapshot's `*_client` views, which omit `id` and actor UUIDs.
- `user_roles.user_uuid REFERENCES auth.users(id)` is the online-only exception; synced content links such as `animal_uuid` intentionally have no server `REFERENCES` constraints.
- Local SQLite uses its own integer `id`, the same global UUID and `*_uuid` relationships, plus client-only `synchronized_at`.
- `created_by_uuid` and review/flag actor UUIDs are attribution for submitted content, not account foreign keys or browsing/activity logs. Deleting an auth user detaches attribution; no append-only user-activity table is defined.
- `db-schema/v1.0.0.sql` describes the MVP tables: `user_roles`, `pilot_settings`, `animals`, `animal_updates`, `listing_flags`, and `care_guides`, with RLS, moderation states, and sync indexes. It is not proof the schema is deployed.
- `photo_path` stores a Supabase Storage object path only. Provision the private bucket and its policies separately before enabling uploads; never store raw sighting/device coordinates in public-location columns.

## Versioning

- Forward changes increment patch versions (`v1.0.1`, `v1.0.2`) in `db-migrations/`.
- Full Supabase exports increment minor versions (`v1.1.0`, `v1.2.0`) in `db-schema/`.
- A snapshot is a clean-provisioning/reference baseline, not a replacement for ordered forward migrations. Never edit an applied migration; see `db-design-choices.md` §10.

## Before applying or changing the schema

1. Confirm the v1.1 MVP proposal and snapshot are approved; confirm the target Supabase PostgreSQL version.
2. Verify local SQLite column names/types, sync payload allowlists, and server policies together. Keep `id` out of client reads and sync.
3. Test out-of-order UUID sync, RLS for anon/authenticated/moderator roles, account deletion/attribution detachment, and soft-delete propagation.
4. Add schema changes as patch migrations; export a new minor-version snapshot only from the reviewed server schema.

**Miss →** A syncable SQL foreign key can reject an offline child before its parent arrives; exposing server `id` can leak server ordering and break device-local identity.

The pilot city, supported species, retention periods, freshness thresholds, and exact safe-location policy remain product decisions. Do not encode guessed values in SQL.

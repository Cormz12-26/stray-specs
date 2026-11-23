# 01 — Architecture

**Purpose:** Describe the current ecosystem boundary and identify what must be confirmed before designing across components.

**Confidence note:** Verified against the current working tree and specs baseline commit `47660a2` on 2026-11-23. The code wins (see 16).

## Model

Stray is described as three products: an API backend that communicates between the Supabase database API and the web/Android clients, a web frontend, and an Android app. The specs repository is intended to hold product and engineering specifications. This is a repository-level model only: there is no implementation to confirm request flow, ownership, deployment topology, or runtime boundaries.

## Components and known ownership

| Component | Evidence in this snapshot | Unknown |
|---|---|---|
| `stray-api` | `AGENTS.md` describes a backend between Supabase and web/Android clients. | Runtime, routes, auth enforcement, data ownership, hosting, and operational behavior. |
| `stray-web` | `AGENTS.md` describes a frontend and mentions regulatory compliance. | Framework, routes, data access, and compliance implementation. |
| `stray-android` | `AGENTS.md` describes the Android application. | Language, architecture, minimum OS, storage, and release process. |
| `stray-specs` | Contains business-logic and workflow guidance. | Whether the templates represent approved requirements or current product behavior. |

## Data flow (intended, not verified)

The API description implies client → API → Supabase and response back to client. It does not establish whether clients can also call Supabase directly. Do not design security boundaries or claim a single path until source code, deployed configuration, and Supabase policies are available.

## Boundaries and decisions

- The only stated integration dependency is Supabase's database API (API `AGENTS.md`); its exact service and access mode are unspecified.
- Google Sign-In appears as a system requirement in `business-logic-v1.0.md`; no OAuth client, token exchange, or identity model is present.
- `business-logic-v1.0.md` remains a template; `business-logic-v1.1-proposed.md` and `db-design-choices.md` describe proposed product and sync decisions. Treat the proposal as intent until approved.
- `db-schema/v1.0.0.sql` is a proposed Supabase snapshot, not evidence that the schema has been deployed or that a local SQLite schema exists.
- No architecture decision records or documented alternatives were found.

## Ranked debt register

1. **Critical evidence gap:** component repositories now have initial documentation commits but no application source. Changes cannot be reviewed against runtime behavior.
2. **Contract gap:** a proposed server schema exists, but no applied schema, local SQLite counterpart, API contract, auth implementation, or client/server version policy exists; integration changes have unknown blast radius (see 04, 07, 08).
3. **Product-definition gap:** the v1.1 proposal is not approved and still leaves pilot geography, species, privacy/retention values, and launch thresholds open.
4. **Operations gap:** no runtime, observability, deployment, or recovery description exists (see 05, 10).

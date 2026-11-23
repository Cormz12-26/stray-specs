# 08 — API

**Purpose:** Record the API's stated role and the contract details that must be discovered before endpoint work.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Known boundary

`stray-api/AGENTS.md` describes a backend that communicates between the Supabase database API and Stray's web and Android clients. No routes, handlers, schemas, validators, authentication middleware, response envelope, versioning, or error codes are available.

## Endpoint inventory

No endpoint is verifiable. Do not assume REST, GraphQL, a URL prefix, response shape, or auth requirement from the repository description.

## Adding or changing an endpoint

1. Find the running API entry point and existing route/validation/error patterns before implementing.
2. Establish the request, response, error, auth, and compatibility contract; check both clients and Supabase schema/policies (see 04, 07).
3. Validate input at the boundary, enforce authorization on the server, and avoid returning secrets or unnecessary personal/location data.
4. Add focused handler and contract tests using the repository's actual test framework; document rollout compatibility.

**Miss →** No contract test can protect web or Android from drift if the server response changes.

These are safety steps for future work, not a description of current behavior. No framework-specific validators or commands are known.

# 13 — Dependencies

**Purpose:** Record dependency evidence and the checks required before adding or upgrading packages.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

## Inventory

No package manifest, lockfile, dependency declaration, runtime version, or third-party license inventory is present. Supabase is named in the API repository description and Google Sign-In in the business-logic template; neither mention proves a particular SDK or package is installed. No deliberate rejection or upgrade trap is documented.

## Change policy

Before adding/upgrading a dependency, identify the owning component, supported runtime, license, security posture, transitive footprint, and maintenance status. Pin and lock versions using the component's established package manager; run its build and relevant tests. Document the concrete reason and migration traps once verified. Do not add a package based only on the placeholder business-logic template.

**Miss →** Without a lockfile and tested runtime, a dependency update can make builds non-reproducible or break an unknown deployment target.

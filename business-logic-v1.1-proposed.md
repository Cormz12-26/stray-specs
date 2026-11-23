# Business Logic — v1.1 MVP Proposal

**Status:** Proposed; this document does not replace `business-logic-v1.0.md`.

## Positioning

**CritterCare Stray** is a community-powered, city-level directory that helps people find known stray animals, understand how to approach and care for them safely, and keep basic animal records current. Start in one pilot city with a small set of approved listings. Stray is a discovery and community-care tool, not an animal-control dispatch, veterinary service, or guarantee that an animal will be present.

**Primary users:** residents who encounter or care for strays, local animal-welfare organizations or caretakers who can verify information, and moderators who keep listings safe and current.

**MVP promise:** show useful, recently reviewed information and safe public-area locations without exposing a contributor's movements or publishing sensitive animal locations.

## Project Details

- **Company/Team:** CritterCare
- **Project Code Name:** Stray
- **Project Short Code:** ST
- **Short Description:** Find and care for city strays with community-verified information.
- **Long Description:** Stray provides a map and directory of approved stray-animal records, basic care guidance, and a lightweight way for community members to submit sightings and care updates. Moderators review new records and location changes. The first release is limited to one pilot city and the animal types and care practices approved for that pilot.
- **Platforms:** Android is the primary community app, built with React Native. The web app provides public access to approved listings and the privacy/contact information, plus a role-protected moderation queue. Avoid feature parity until the pilot demonstrates a need.
- **Initial stack named by v1.0:** React Native, Supabase, and Google Maps SDK. Confirm exact services, access policies, and client configuration during technical design; this proposal does not assert an existing implementation.

## User Levels

| Level | Role | MVP permissions |
|---|---|---|
| A | System Administrator | Manage technical access and recovery; grant or revoke elevated roles; handle authorized privacy/data requests. Access sensitive record data only when needed for an approved operational task. |
| B | Administrator | Manage pilot settings and listing lifecycle; review aggregate activity and moderation health. Cannot grant system-administrator access. |
| C | Moderator | Review, approve, correct, hide, or archive listings; review safety flags and duplicate reports. Cannot change system security settings or roles. |
| D | Contributor | After Google sign-in, submit a listing, suggest an update, record a basic care action, or flag inaccurate information. May edit own pending submissions; cannot approve public records. |
| E | Guest | Browse approved public listings and care guidance; may submit a limited safety/inaccuracy flag without an account. Cannot create or edit a listing. |

Assign roles server-side; a client must not be able to promote its own account. All users, including administrators, follow the same public-location safety rules.

## System Requirements

1. The app shall let guests browse approved stray profiles in a map or list without signing in; sign-in is required for contributor actions.
2. The app shall authenticate contributors with Google Sign-In and grant only the default contributor role unless an administrator assigns a higher role.
3. The app shall let contributors submit a stray record with only MVP fields: animal type, observation date, short description, and a proposed public-area location; a photo is optional.
4. The app shall show each approved profile's review/update date, safe public-area location, and concise care guidance. It shall not publish a private address, nest/den location, or exact sensitive coordinates.
5. The app shall let signed-in contributors submit a small set of structured sighting or care updates. It shall not collect route history, background location, map-view history, or a public per-user activity feed.
6. The app shall let guests and signed-in users flag an inaccurate, unsafe, duplicate, or outdated listing. New listings and public-location changes shall remain unpublished until moderator review; moderators shall be able to hide a listing promptly.
7. The system shall enforce role-based access, support account/data deletion requests, apply an approved retention schedule, and provide only thresholded aggregate reports without individual-level user trails.

## Required Solution Layers

1. **Privacy and legal review:** Collect the minimum data needed. Publish a privacy notice and retention/deletion rules before launch. Verify applicable Data Privacy Act obligations with the responsible privacy/legal reviewer; do not claim compliance based only on this proposal.
2. **Location and animal safety:** Store precise coordinates only if needed for moderation or care operations, restrict them to authorized roles, and publish only an approved landmark or generalized area. Do not expose contributor device location, private property, or sensitive animal locations.
3. **Authentication and authorization:** Validate Google identity server-side. Enforce roles and record visibility in the trusted service/database layer, not only in the UI. Keep service credentials out of client apps and logs.
4. **Data quality and moderation:** Mark records as pending, approved, hidden, or archived. Show when information was last reviewed. Provide a report/hide path and a human moderator; do not present unreviewed submissions as verified.
5. **Responsible care:** Give brief, reviewed, non-medical guidance. Do not promise rescue, veterinary diagnosis, emergency response, or animal availability. Provide a locally approved contact path for urgent welfare concerns before launch.
6. **Analytics and use:** Use aggregate counts only, with a minimum group-size threshold selected before any report is shared. Do not sell or resell personal, contributor, or location data in the MVP; any future data sharing needs explicit review and consent where required.

## MVP Features and Access

| MVP feature | A | B | C | D | E |
|---|:---:|:---:|:---:|:---:|:---:|
| Browse and filter approved map/list records and read care guidance | ✓ | ✓ | ✓ | ✓ | ✓ |
| Submit a new listing or structured sighting/care update | ✓ | ✓ | ✓ | ✓ | — |
| Flag an unsafe, inaccurate, duplicate, or outdated listing | ✓ | ✓ | ✓ | ✓ | ✓ |
| Review, approve, correct, hide, or archive submitted records | ✓ | ✓ | ✓ | — | — |
| Manage pilot settings and view aggregate moderation/listing counts | ✓ | ✓ | — | — | — |
| Manage elevated roles and authorized technical/privacy operations | ✓ | — | — | — | — |

## MVP Boundaries

**In scope:** one pilot city; a curated public map/list; approved animal profiles; safe location display; basic care guidance; Google sign-in for contributions; structured updates and flags; moderation; essential privacy/contact information; aggregate operational counts.

**Not in scope:** payments or donations, chat, social feeds, gamification, live animal tracking, public exact coordinates, rescue dispatch, veterinary diagnosis/treatment, city-wide analytics about individuals, multi-city rollout, or complex volunteer scheduling. Reconsider only after pilot evidence supports the need.

## Pilot Launch Criteria

- Select the pilot city, supported animal types, and at least one accountable local moderator or welfare partner.
- Approve the public-location rules, care guidance, urgent-contact route, privacy notice, and retention/deletion periods before publishing records.
- Seed and review an initial set of listings; every public listing must have an approved safe location and a visible last-reviewed date.
- Test guest, contributor, moderator, administrator, and system-administrator permissions, including denial of unauthorized role changes and access to precise coordinates.
- Test report, hide, correction, and deletion-request workflows on both supported surfaces.
- Review only aggregate measures: approved active listings, stale/unreviewed listings, submitted care updates, and moderation backlog. Set freshness and group-size thresholds before the pilot; do not collect user-level location or browsing histories.

## Notes and Decisions Required Before Build

The following are product decisions, not implementation details to guess:

1. Name the first pilot city and the organization/person accountable for moderation and urgent welfare referrals.
2. Confirm which animal types are supported initially and who approves care guidance.
3. Define what qualifies as a “stray” listing and the evidence needed to avoid listing owned animals without permission.
4. Approve location precision by risk category, record freshness/expiry rules, and retention periods for submissions, photos, and moderation records.
5. Confirm the applicable privacy jurisdiction and review the privacy notice, lawful basis, consent, deletion, and data-subject request process.
6. Decide whether web includes only public discovery and moderation, or whether contributor workflows are also necessary. Keep one authoritative workflow unless pilot feedback justifies duplication.
7. Set launch thresholds for listing freshness, moderation response, and minimum group size for aggregate reporting.

Until these decisions are approved, treat the scope as a focused proposal rather than a complete, launch-ready specification.

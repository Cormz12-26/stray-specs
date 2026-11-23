# 12 — Performance

**Purpose:** Keep performance claims and optimization decisions tied to measurements.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

No latency/throughput targets, workload, device matrix, hot path, database query, cache, hard limit, profiler, or benchmark exists in the supplied files. It is not possible to identify deliberate inefficiencies or rank expensive operations.

Before optimizing, define the affected user action and acceptable threshold, capture a baseline on a representative build/data set, profile the actual client/API/database path, then verify the same threshold after the change. Keep privacy constraints in force when collecting traces or benchmark data; do not retain user-level location trails. Record the workload and tool with any result so it can be reproduced.

**Miss →** Optimizing an assumed bottleneck can add complexity without improving user-visible performance; collecting detailed traces can violate the stated privacy intent (see 09).

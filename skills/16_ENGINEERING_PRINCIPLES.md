# 16 — Engineering principles

**Purpose:** State evidence-backed rules for developing Stray without confusing written intent with runtime behavior.

**Confidence note:** Verified against the supplied working-tree snapshot (no commit exists) on 2026-11-23. The code wins (see 16).

1. **Evidence outranks assumption.** The app repositories have no tracked implementation, while the business-logic spec contains placeholders; guessing APIs or build steps would teach behavior that cannot be verified. Evidence: 01, 02, and 06 #1.
2. **Treat a requirement as intent until a control is verified.** Google Sign-In and privacy protections appear in a template, not source or tests; claiming enforcement without proof can create a false security or compliance assurance. Evidence: 09 and 15.
3. **Change contracts with all known consumers.** The API description names Supabase plus web and Android clients, but supplies no schema or contract; updating only one side risks integration drift. Evidence: 04 and 08.
4. **Release approval is a gate, not a branch name.** The written workflow separates QA, published integration testing, and production approval; treating a `release` branch as approval can ship an untested build. Evidence: `git-guidelines.md` and 10.
5. **Preserve incident evidence, never invent a scar.** No incident can be reconstructed from this snapshot; a plausible failure presented as history would misdirect future debugging. Evidence: 05 and 06 #1.

These principles summarize current written evidence, not proof that the practices are implemented. Trust the code over any document, including this one.

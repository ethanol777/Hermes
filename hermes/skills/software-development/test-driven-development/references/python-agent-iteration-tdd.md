# Python Agent Project Iteration via TDD

Use this reference when a user asks for an open-ended improvement to an existing Python agent project.

## Pattern

1. Inspect the project structure and existing plans/PRDs.
2. Read live call sites, not just class definitions. Look for interface contracts already implied by callers.
3. Pick one small, high-value behavior. Good targets:
   - caller invokes a method alias that the callee does not provide;
   - boundary accepts only one data shape but callers pass another;
   - repeated writes can flood memory/state without deduplication;
   - custom runner and pytest disagree about coverage surface.
4. Write a focused pytest regression test first.
5. Run the focused test and confirm it fails for the intended reason.
6. Implement the smallest compatible change.
7. Verify in three layers when available:
   - focused new test;
   - project-native test runner for legacy expectations;
   - full pytest suite for standard discovery.
8. Clean warnings as part of completion if they are introduced or surfaced by the touched files.

## Concrete example from a session

A CLI route called `warm.add(...)`, while `WarmLayer` only exposed `add_memory(...)`. The TDD target was not a broad memory-system redesign; it was the implied interface contract:

- add `warm.add(...)` as a compatibility alias;
- accept `tags` as either `str` or `list[str]` at the boundary;
- deduplicate exact normalized content so repeated emotional/memory writes do not grow state unbounded;
- merge tags and keep the higher importance on duplicate writes.

Verification used both the project's custom runner and pytest because each covered a different compatibility surface.

## Environment hygiene note

If a Python virtualenv fails with interpreter-internal mismatch errors after being invoked from an agent shell, check for outer environment variables such as `PYTHONHOME` leaking into the child process. Prefer cleaning the environment for that command over encoding the transient failure as a permanent tool limitation.

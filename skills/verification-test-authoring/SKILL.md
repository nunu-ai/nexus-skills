---
name: verification-test-authoring
description: Author, port, and edit high-quality verification tests for the nunu.ai (nexus) platform. Use this whenever the user wants to create, write, port, convert, restructure, review, split, or update a verification test. Default to using it for anything that looks like writing or editing nunu/nexus tests, even if the user doesn't say "skill".
---

# Nunu Verification Tests

## What a verification test actually is
A verification test is **an ordered, grouped list of checks**, wrapped in just
enough instruction that an executor (a human or an agent) can walk the app once
and confirm every check along the way.

We often call a check also verification item, expected result, acceptance criteria or a (testrail) test case.

The process of making a good test case consists of:
1. **Enumerate the checks** — the atomic pass/fail facts you need to confirm. One check ≈ one TestRail test case.
2. **Group checks that share a screen or moment** into a **step**, and write the shortest `instruction` that gets the executor there.
3. **Order the steps** into the most efficient single walk through the app.
4. **Group steps** into **collections** by setup / feature so they're reusable and readable.
A good verification test is that route, written down.

Before writing your first test, read [references/examples.md](./references/examples.md) for worked examples of complete verification tests.

## Writing checks
A check must be **unambiguously true or false by observing the app at the moment
the step reaches it.
- **Specific.** Name the element and the expected value. "there is a play, settings and quit button", not "the main menu looks correct".
- **Atomic.** One idea per check. Bundle multiple facts only when they always pass or fail together, otherwise a failure won't tell you which thing broke.
- **Being too specific.** A check must hold on *every* valid run. If a value can legitimately change run to run, don't pin the literal value
- **Banned Words.** Avoid words like correctly, good, properly, expected.

| Bad (ambiguous) | Good (binary, observable) |
|---|---|
| The avatar shows correctly | The selected avatar appears in the profile carousel card, the main header, and the side-menu header |
| Game loads in expected time | The game loads in less than 1 minute |
| Profile open properly | Tapping Settings opens a screen whose header text reads "PROFILE" |
| Name changed successfully | The username field and main header both display "William" |
| All headers are there | The section labels GAMEPLAY, GRAPHICS, LANGUAGE, AUDIO and KEYBOARD are each visible |
| Login works | After submitting valid credentials, the dashboard screen appears |
| You are matched with opponent "Bot_Kappa" | After matchmaking, an opponent name is displayed |
| Winning the mini game 234 gold is added to your balance | After winning the mini game the displayed reward is added to your balance |

**Never make a check conditional to work around missing data.** Rewriting
"clicking Archive removes the bug from the list" into "*when a bug is listed*,
clicking Archive removes it from the list" makes the check pass without being
exercised, and nothing in the result says it never ran.

When porting from TestRail, keep **one check per TestRail case** so each maps 1:1 and traceability stays clear. Link the ordered case IDs on the step's optional `testrail_case_ids`; the structured `expected_results` entries carry the check text.

## Writing good Steps
A step's `instruction` is actionable. Write the minimum imperative instructions that move the executor to the point where the step's check can be performed. Keep observations out of the instruction, they belong in checks.
- **Imperative and lean.** "Open the hamburger menu, then tap Settings." If detail isn't needed, stay high-level. Don't write a book
- **One screen / one operation per step.** Bundle all checks visible at that point into the step's `expected_results` (one entry per check). Verifying multiple section labels on the Settings screen is *one* step, not multiple.

**Hints**
Tests and setups are often flaky: unexpected popups, saved account data, and
mistakes such as clicking the wrong button can change the path. Use the `hints`
array for optional situations and error recovery/prevention; these do not belong
in the `instruction`.
"don't click the blue button"
"if you land on X, tap back"
"always choose new game+ if it's available"

**Every state a hint names needs an attached action.** The examples above all do
this — they say what to do, not just what might happen. A hint that only
describes a state leaves the executor to invent a response, and different runs
will invent different ones. "The run may show as tearing down, which means it
already finished" tells the executor what it is seeing and nothing about what to
do, so one run reports a defect and another relaunches and retries. Write "...if
it shows as tearing down it already finished; start it again and resume polling"
instead.

## Ordering and grouping
Order the steps as the **most efficient single walk** through the app:
- **Setup first.** Launch, log in, reset user data, reach the screen under test.
- **Follow the natural flow.** Minimize back-and-forth navigation. If three checks all live one tap apart, make them consecutive steps.
- **Group by feature.** All of Feature A's steps together, then Feature B's.
- **Destructive/irreversible last.** Account deletion, build deletion, logout, put them at the end or isolate them so they don't strand later checks.
- **Cleanup steps at the end are the ones most likely to be blocked**, because anything failing earlier cascades into them. Assume they will sometimes not run, and make the test's opening steps tolerant of what they would have removed.

## Step Collections
A collection is a named bundle of steps. Use them for two things:
- **Shared Steps** Create a reusable collection with `create_shared_step`, then reference its returned ID with an item of type `shared_steps`. This is very useful for common setup steps.
- **Grouping for Readability** Group related steps, for example by feature or phase in the test, giving a good label makes the test more readable

## Execution time budget

Set whole-test `budget.max_seconds` to **about 3× your runtime estimate**:
AI executor agents need extra time to observe, reason, and recover. A five-minute
estimate should get fifteen minutes (`900` seconds); longer flows need more.
If a timeout interrupts useful progress, increase the budget 2–3×. Respect
explicit user limits and keep product timing checks unchanged.

## Authoring shape

The examples in [references/examples.md](./references/examples.md) are payloads for
`create_verification_test`, not the response from `get_test`:

- The top level contains `name`, optional `project_id`, `tags`, `folder_path`,
  `budget`, and a `players` array. Include `project_id` when the credentials
  can access multiple projects; `infra-test` and `nexus` are valid examples in
  the nunu.ai organization. The create tool already knows this is a verification test;
  do not add a `test` wrapper or `test_type`.
- Each player has a name, an `agent_config_id`, and ordered `items`. Resolve
  agent config IDs with `list_project_resources` using `resource: "agent_configs"`.
- A step item has `type: "step"`, `instruction`, `expected_results`, and
  optional `hints` and `testrail_case_ids`. `expected_results` may be a string
  or an array; use an array when there are multiple checks.
- An inline collection has `type: "collection"`, a name, and ordered `steps`.
  Its nested steps use the same `instruction`, `expected_results`, and `hints`
  fields and may also include `testrail_case_ids`, but do not have their own
  `type`.
- A shared collection is referenced as `{ "type": "shared_steps",
  "shared_collection_id": "..." }`; do not inline or edit its steps in the
  test payload. Find IDs with `list_shared_steps`.

`get_test` returns useful read-only fields such as `player_id`, `step_id`,
`collection_id`, and `is_shared`. Do not copy those server-managed fields into a
new create payload. For small edits, use `update_verification_test` with the
version from `get_test` and flat one-based `step_id` selectors.

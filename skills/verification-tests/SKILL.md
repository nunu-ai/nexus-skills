---
name: verification-tests
description: Author, port, and edit high-quality verification tests for the nunu.ai (nexus) platform. Use this whenever the user wants to create, write, port, convert, restructure, review, split, or update a verification test. Default to using it for anything that looks like writing or editing nunu/nexus tests, even if the user doesn't say "skill".
---

# Nunu Verification Tests

## What a verification test actually is
A verification test is a **an ordered, grouped list of checks**, wrapped in just
enough instruction that an executor (a human or an agent) can walk the app once
and confirm every check along the way.

We often call a check also verification item, expected result, acceptance criteria or a (testrail) test case.

The process of making a good test case consists of:
1. **Enumerate the checks** — the atomic pass/fail facts you need to confirm. One check ≈ one TestRail test case.
2. **Group checks that share a screen or moment** into a **step**, and write the shortest instruction (the step's *goal*) that gets the executor there.
3. **Order the steps** into the most efficient single walk through the app.
4. **Group steps** into **collections** by setup / feature so they're reusable and readable.
A good verification test is that route, written down.

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

When porting from TestRail, keep **one check per TestRail case** so each maps 1:1 and traceability stays clear. (Per-result TestRail linking on the API surface is coming; for now the structured `expected_results` entries carry only the check text.)

## Writing good Steps
A step's `goal` is actionable. Write the minimum imperative instructions that move the executor to the point where the step's check can be performed. Keep observations out of the goal, they belong into checks.
- **Imperative and lean.** "Open the hamburger menu, then tap Settings." If detail isn't needed, stay high-level. Don't write a book
- **One screen / one operation per step.** Bundle all checks visible at that point into the step's `expected_results` (one entry per check). Verifying multiple section labels on the Settings screen is *one* step, not multiple.

**Hints**
test and setups are often flaky, unexpected popups appearing, saved account data etc and other things might happen. Additionally the executor might make mistakes, clicking on a wrong button, accidentally resetting progress etc. To clarify how these situations should be handled, the hint manual exists. It's mainly for handling optional situations and error recovery/prevention. These things then don't belong into the instructions
"don't click the blue button"
"if you land on X, tap back"
"always choose new game+ if it's available"

## Ordering and grouping
Order the steps as the **most efficient single walk** through the app:
- **Setup first.** Launch, log in, reset user data, reach the screen under test.
- **Follow the natural flow.** Minimize back-and-forth navigation. If three checks all live one tap apart, make them consecutive steps.
- **Group by feature.** All of Feature A's steps together, then Feature B's.
- **Destructive/irreversible last.** Account deletion, build deletion, logout, put them at the end or isolate them so they don't strand later checks.


## Step Collections
A collection is a named bundle of steps. Use them for two things:
- **Shared Steps** Saving a collection with `is_shared: true` allows reuse across different Verification Tests. This is very useful for common setup steps.
- **Grouping for Readability** Group related steps, for example by feature or phase in the test, giving a good label makes the test more readable

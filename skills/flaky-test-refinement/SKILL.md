---
name: flaky-test-refinement
description: Fix flaky nexus verification tests by refining their instructions and hints against past run history — diffing runs where a step passed against runs where it failed, then locking in the path that worked. Use whenever someone asks why a test is flaky, why the same build gives different results, why runs are green one time and red the next, why the agent reports bugs that aren't real, why a run got blocked, or asks to tighten, stabilize, refine, or pin a test case. Also when someone shares run IDs or test plan executions, or asks to compare runs — including one-off "why did this run fail?" questions.
---

# Refining flaky verification tests

When a test gives different results on the same build, the product almost always
behaved identically and the agent took a different path. Find the divergence,
then refine the instructions and hints so the agent stays on the path that worked
and avoids the one that failed.

Core move: **find a run where the step passed and a run where the same step
failed, and diff them.**

## 1. Build the matrix

Single test case:

```
list_entities(type="past_runs", test_case_id=<id>)
```

Whole plan:

```
list_entities(type="test_plan_executions", test_plan_id=<id>)
list_entities(type="past_runs", test_plan_execution_id=<id>)   # per execution
```

Either way, lay out runs against results and step-result summaries
(`{"SUCCESS": 5, "FAILED": 1, "BLOCKED": 2}`). Look for which steps fail, whether
failures repeat or scatter, whether whole executions cluster.

A test that passes at least once is flaky. One that never passes may be a real
defect — say so instead of hunting for an agent divergence.

## 2. Establish what varied between runs

Do this before comparing anything. Runs that differ in configuration are not
replicates, and diffing across them produces confident wrong answers.

Check every axis, not just platform:

- **Test version** — `test_version` on the run. Runs of different versions are
  different tests.
- **Build** — `list_entities(type="builds")`; executions filter by `build_id`.
- **Deployment config** — `list_entities(type="deployment_configs")` gives each
  config's `kind` plus its own environment settings (geolocation, locale, network
  conditions, build source).
- **Device** — one config can cover several devices via `deviceLabels`, and runs
  started across all configured devices land on different hardware.
- **Agent config** — overridable per run, so two runs of one test can use
  different agents.
- **Template data** — when a test uses Handlebars variables, different
  `templateData` means the agent saw different instructions.
- **Per-player / per-slot configs** — multiplayer tests can mix platforms across
  players.

Group runs by configuration and compare only within a group. When executions
varied on an axis, say which — the person may not realize their three runs of
"the same thing" weren't.

Platform is usually the axis that explains the most, because it changes how the
agent perceives and acts:

| Kind | Driven by | Reads state from | Characteristic failures |
|---|---|---|---|
| **browser** | CDP — `Page.navigate`, `Runtime.evaluate`, `Input.dispatchMouseEvent` | DOM / accessibility tree | Reads landing before render settles; hard navigation hanging an SPA; losing track of the focused tab |
| **desktop VM** (windows, macos) | Real mouse and keyboard, native dialogs and file pickers | Screenshots | Coordinate drift; unmaximized windows; OS dialogs stealing focus; native picker paths |
| **android / ios** | Taps, swipes, device automation | Screenshots, sometimes a view hierarchy | Density and resolution differences; permission prompts; keyboard covering targets; app state persisting between runs |

Two properties do most of the predicting:

**How the agent reads state.** Structural reads (DOM, view hierarchy) return
whatever exists at that instant, including a half-rendered screen, so they
produce "it's missing" false positives. Visual reads can't return before the
pixels exist, but break on anything positional.

**Whether the agent's filesystem is the target's filesystem.** On browser
deployments the sandbox often bridges to the page. On a VM or physical device it
does not, and any approach assuming shared storage fails in a way that looks like
a product bug. File handling almost always needs a per-platform branch.

## 3. Diff matched pairs

```
inspect_run(run_id=<fail>, view="events", scope={"step": N}, filters={"preset": "narrative"})
inspect_run(run_id=<pass>, view="events", scope={"step": N}, filters={"preset": "narrative"})
```

The narrative preset interleaves thinking with actions. You're looking for the
moment the two runs stopped doing the same thing — usually a single decision: one
polled, the other slept; one located the element, the other reused a coordinate.

Watch step duration. Eight minutes in the failing run against forty seconds in
the passing one tells you where the agent got lost.

## 4. Verify against screenshots before believing the trace

Screenshots are ground truth. Reasoning traces are the agent's interpretation,
and they hide wrong assumptions — an agent that misread the screen will narrate
its misreading with total confidence.

When a failure hinges on what the UI was showing — a stalled operation, an empty
list, a control that "did nothing" — pull the image:

```
get_run_image(run_id=<id>, image_ref="<event_ref>#img0")
```

One trace read "the dialog confirms the upload is in progress"; the agent waited,
retried, filed a high-severity bug. The screenshot showed the dialog still
pre-submit with the submit button visible — nothing had been submitted, and the
click had landed outside the window.

Where a bug was reported, the screenshot decides whether it's real.

## 5. Classify the cause — the class determines the fix

| Class | Signature | Fix |
|---|---|---|
| **Strategy divergence** | Both paths could work; agent picked different tools | Pin the winning path — exact tool, selector, route |
| **Config difference** | Correct method genuinely differs by platform, device, or environment | Branch the hint per config |
| **Timing / settling race** | State read before the UI finished updating | A positive precondition (see below), not a longer wait |
| **Positional drift** | Interaction landed elsewhere — window size, layout shift, density, keyboard | Locate the element fresh; forbid remembered coordinates |
| **Environment state leakage** | Prior run left the app logged in, cached, permission-granted, mid-flow | Make the step establish its own starting state |
| **Fixture dependency** | Step needs shared data that runs consume, or another test produces | Skip clause in the goal, or seed in-step |
| **Real defect** | Reproduces on every run and every config | Leave it. Report it |

Refinement is biased toward making red things green, so run on a genuine defect
it will teach the suite to ignore it. When you can't tell a bug from a quirk, say
so rather than encoding "known quirk" on a hunch.

## 6. Put the fix in the right slot

- **Goal** — what to do, including legitimate variation. Optional paths and skip
  conditions go here, in plain sight: `"...then archive it. If nothing is listed,
  this step and its check can be skipped."`
- **Expected results** — binary observable facts. Never rewrite a check into a
  conditional ("when X is available, then Y") to dodge a fixture problem; that
  passes vacuously and hides the gap. Use a skip — skips show in the run and in
  the plan's `skipped` bucket, vacuous passes don't.
- **Hints** — recovery, disambiguation, known traps, per-config branches.

Before editing, read
[verification-test-authoring](../verification-test-authoring/SKILL.md); it
defines what makes a good check and is what the existing tests were written
against.

## 7. Ship

**Ask first whether to edit the test in place or copy it.** In place is usually
what people want. A copy is for when the baseline has to stay runnable for
comparison, or when the change is large enough to want a fallback. Don't assume
either way.

- **Editing in place** — `update_test_case` needs `expectedVersion`, and never
  echo server-managed fields (`test_step_id`, `composite_test_id`, collection
  `version` / `created_at` / `created_by`); the strict schema rejects the whole
  call.
- **Copying** — `create_test_case`, then add it to a plan if it needs to run
  alongside others.
- **Either way, don't inline shared collections.** Pass `collection_id`,
  `is_shared: true`, empty `steps_by_key`, `sharedCollectionStepsMode: "drop"`.
  Editing a shared collection changes every test using it. The API rejects
  inlined shared steps unless you pass `"drop"`.
- **Re-run and re-diff.** Not confirmed until the step passes on every config it
  previously failed on. Check the failure didn't just move.

## Anti-patterns

**A bug-reporting procedure for a state you haven't proven exists.** "If it's
still in progress after two minutes, retry once, then report a defect" presumes
the observation is real. If the agent's reading of the screen is itself the bug,
this upgrades a hesitant false positive into a confident one with evidence
attached.

**Waiting ladders instead of positive preconditions.** "Wait longer, then check
again" leaves the agent guessing. Give one binary observable:

> While the cancel and submit buttons are visible, nothing has been submitted.
> Submission has happened only once that button row is gone.

Find the element whose presence or absence is unambiguous and anchor to that.

**Naming a failure state without prescribing the response.** "The job may show as
tearing down, meaning it already finished" tells the agent what it sees but not
what to do, so one run reports a bug and another retries. Every described state
needs an attached action.

**Remembered coordinates.** Any coordinate carried across steps or runs is a
latent failure: windows may not be maximized, dialogs grow when content attaches,
devices differ in density, keyboards cover the lower third of a phone. Locate
before interacting, then confirm the interaction landed by checking for a state
change.

**Racing another test for shared state.** Tests in a plan often start
concurrently. If one produces the data another consumes, pass rate becomes a
function of scheduling. Suspect this when failures correlate with what ran
alongside rather than with the build.

**Retries instead of diagnosis.** They raise the green rate without fixing
anything and double the cost. At ~2/3 per-test pass rate, four tests give roughly
20% odds of an all-green plan; one retry each takes it to ~62%. A stopgap after
paths are pinned, not a replacement.

## Reporting back

Lead with the matrix — which step, which runs, which config — then the matched
pair diff per root cause, then the fix. Quote the specific divergence (the sleep
duration, the selector, the coordinate) rather than describing it abstractly;
that's what makes the diagnosis checkable.

Distinguish "the screenshot proves this" from "this is the most likely
explanation." The person reading usually knows the product and can confirm or
correct a stated hypothesis faster than they can unpick a confident wrong one.

## Measuring

Per-run pass rate mixes configs together. Track **per-step pass rate per
config**. A step 1-for-2 on one platform and 0-for-1 on another is two problems
sharing a step number.

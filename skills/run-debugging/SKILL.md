---
name: run-debugging
description: Investigate failed, stuck, slow, or suspicious nexus runs by correlating run events, device and service logs, screenshots, and recordings. Use for run diagnosis, agent behavior analysis, capture problems, and artifact or infrastructure failures; supports local and remote MCP artifact access.
---

# Debugging nexus runs

Reconstruct what happened from evidence. A run verdict or agent summary alone
does not explain the cause, and successful tool calls do not prove the intended
app action succeeded.

## Find the relevant window

- Start with `inspect_run(view="outline", include=["artifacts", "bug_occurrences"])`.
  Resolve the attempt and player; keep that composite run ID for follow-ups.
  Preserve a supplied link's `p` as `scope.share_position` and `a` as
  `filters.agent`.
- Read the failed step or suspicious interval with `view="events"` and
  `filters.preset="narrative"`. Open important `event_ref` values with
  `view="event"`; use `view="map"` to locate long gaps in large runs.
- Use `view="search"` for claims such as whether a tool was ever used. Follow
  pagination and check coverage before claiming absence or counting usage;
  the end of an events page is not necessarily the end of the run.

## Get artifacts onto the local filesystem

Discover exact `file_ref` values from the outline; do not guess filenames.
Use `get_run_file` for inline text and images. For large logs, event dumps, or
video, inspect the available `download_run_files` schema: the two MCP versions
share a name but accept different arguments.

- **Local MCP:** accepts `run_id`, `destination_dir`, and optional `files`
  selectors such as `[{"file_ref":"artifact:<returned path>"}]`, and writes
  files into the workspace. Check per-file failures, preserve player folders,
  and use the reported destination. Existing files are preserved.
- **Remote MCP:** accepts a single player's `run_id` and one `file_ref`, and
  returns `download_url` and `headers`. Download it yourself, copying the URL
  and required headers exactly. Preserve quotes inside `headers["If-Match"]`:

  ```sh
  curl --fail --location --output ./artifact.log \
    --header 'If-Match: "<returned etag>"' '<returned download_url>'
  ```

Search downloaded logs with `rg -n -C` and parse structured files with `jq` 
or a short script, keeping surrounding context. Keep signed URLs 
and credentials out of reports.

## Correlate events, logs, and pictures

- Normalize timestamps to UTC and align run-relative events with device logs
  and video. Verify the recording offset from metadata or a shared visible
  event; video time zero need not equal run time zero.
- Inspect screenshots with `get_run_file`. For recordings, use `ffprobe` to
  check duration, then extract a short clip or timestamped frames with `ffmpeg`.
  View the frames; sample more densely around brief transitions or missed cues.
- Compare what the agent observed, decided, and executed with what visibly
  happened. Distinguish a watch firing or controller activation from the
  resulting action succeeding. Check for stale observations and unattended gaps.
- For capture problems, compare available screenshot sources with footage and
  device logs. Fresh timestamps or incoming packets alone do not prove healthy
  decoded frames. A visual artifact can originate in capture rather than the app.

## Explain the cause

Separate confirmed facts from hypotheses. Classify the problem as app behavior,
test expectations, agent strategy, configuration, or infrastructure/capture,
and say what evidence would resolve any uncertainty. When comparing runs, match
test/build/config versions and device before attributing differences to strategy.

Report the outcome, the decisive timestamped evidence, and the smallest next
fix or experiment. Use `inspect_run(view="event")`'s `links.human_view` for
event links. Missing footage or incomplete log coverage is a limit to state.

For instruction or hint changes to stabilize inconsistent tests, continue with
[flaky-test-refinement](../flaky-test-refinement/SKILL.md). For reported bug
dispositions, use [bug-review](../bug-review/SKILL.md).

# nexus-skills

skills for the [nunu.ai](https://nunu.ai) nexus mcp/platform.

## Install

### In Claude Code

```shell
/plugin marketplace add nunu-ai/nexus-skills
/plugin install nexus-skills@nunu-ai
```

### In Codex

Add this repository as a Codex plugin marketplace:

```shell
codex plugin marketplace add nunu-ai/nexus-skills
```

Then restart Codex, open the plugin directory, choose the `nunu.ai Plugins`
marketplace, and install `Nexus Skills`.

## Update

### In Claude Code

Refresh the marketplace first, then update the installed plugin:

```shell
/plugin marketplace update nunu-ai
/plugin update nexus-skills@nunu-ai
```

### In Codex

Open the plugin directory, choose the `nunu.ai Plugins` marketplace, and update
`Nexus Skills`.

## Skills

- **verification-tests** — author, port, and edit high-quality verification tests for the nexus platform

## Release

This repo releases from tags. The release workflow checks that the tag matches
the plugin manifest version, zips the `skills/` folder as `skill.zip`, creates a
GitHub release, and uploads the zip as a release asset.

Use conventional commits for normal changes:

```shell
git commit -m "fix: clarify settings verification checks"
git commit -m "feat: add build storage verification guidance"
```

When ready to release, use `just release` from a clean worktree:

```shell
just release        # patch release, for fixes
just release minor  # minor release, for features
just release major  # major release, for breaking changes
just release 1.2.3  # explicit version
```

The release command bumps both plugin manifests, commits the version bump,
pushes the branch, creates the matching `vX.Y.Z` tag, and pushes the tag.

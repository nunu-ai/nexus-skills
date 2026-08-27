# Development

## Commits

Use conventional commits for normal changes:

```shell
git commit -m "fix: clarify settings verification checks"
git commit -m "feat: add build storage verification guidance"
```

## Releases

This repository releases from tags. The release workflow checks that the tag
matches the plugin manifest version, zips the `skills/` folder as `skill.zip`,
creates a GitHub release, and uploads the zip as a release asset.

Run the release command from a clean worktree:

```shell
just release        # patch release, for fixes
just release minor  # minor release, for features
just release major  # major release, for breaking changes
just release 1.2.3  # explicit version
```

The command bumps both plugin manifests, commits the version bump, pushes the
branch, creates the matching `vX.Y.Z` tag, and pushes the tag.

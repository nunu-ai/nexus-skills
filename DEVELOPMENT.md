# Development

## Commits

Use conventional commits for normal changes:

```shell
git commit -m "fix: clarify settings verification checks"
git commit -m "feat: add build storage verification guidance"
```

## Releases

This repository releases from tags. The release workflow checks that the tag
matches the plugin and npm package versions, bundles `skills/` and `LICENSE`
in `skill.zip`, and uploads the zip as a GitHub release asset.

Run the release command from a clean worktree:

```shell
just release        # patch release, for fixes
just release minor  # minor release, for features
just release major  # major release, for breaking changes
just release 1.2.3  # explicit version
```

The command bumps the plugin manifests and npm package, commits the version
bump, pushes the branch, creates the matching `vX.Y.Z` tag, and pushes the tag.

## Test the Cursor plugin locally

1. Copy the repository to `~/.cursor/plugins/local/nexus-skills` so the folder
   contains `.cursor-plugin/plugin.json`, `skills/`, and `mcp.json`.
2. Run **Developer: Reload Window** in Cursor and open **Customize**.
3. Confirm that **Nexus Skills** exposes the four skills listed in the README
   and the `nunu` MCP server.
4. Select **Connect** for `nunu`, sign in to Nexus, and ask Cursor to list the
   Nexus projects you can access.

set shell := ["bash", "-euc"]

_semver_regex := '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

default:
    @just --list

version:
    @jq -r '.version' .codex-plugin/plugin.json

bump kind='patch':
    @current=$(jq -r '.version' .codex-plugin/plugin.json); \
      bump="{{kind}}"; \
      if [[ "$bump" =~ {{_semver_regex}} ]]; then \
        next="$bump"; \
      else \
        base="${current%%[-+]*}"; \
        IFS=. read -r major minor patch <<< "$base"; \
        case "$bump" in \
          patch) next="$major.$minor.$((patch + 1))" ;; \
          minor) next="$major.$((minor + 1)).0" ;; \
          major) next="$((major + 1)).0.0" ;; \
          *) echo "Invalid bump: $bump (use patch, minor, major, or x.y.z)"; exit 1 ;; \
        esac; \
      fi; \
      [[ "$next" =~ {{_semver_regex}} ]] || { echo "Invalid version: $next"; exit 1; }; \
      VERSION="$next" perl -0pi -e 's/"version"\s*:\s*"[^"]+"/"version": "$ENV{VERSION}"/' .codex-plugin/plugin.json .claude-plugin/plugin.json; \
      codex_version=$(jq -r '.version' .codex-plugin/plugin.json); \
      claude_version=$(jq -r '.version' .claude-plugin/plugin.json); \
      test "$codex_version" = "$claude_version" || { echo "Version mismatch: codex=$codex_version claude=$claude_version"; exit 1; }; \
      echo "Bumped nexus-skills from $current to $next"

tag:
    @test -z "$(git status --porcelain)" || { echo "Commit version bump before tagging."; exit 1; }; version=$(jq -r '.version' .codex-plugin/plugin.json); git tag "v$version" && echo "Created tag v$version"

release kind='patch':
    @test -z "$(git status --porcelain)" || { echo "Commit or stash existing changes before releasing."; exit 1; }
    @just bump "{{kind}}"
    @version=$(jq -r '.version' .codex-plugin/plugin.json); \
      git add .codex-plugin/plugin.json .claude-plugin/plugin.json; \
      git commit -m "chore: bump version to $version"; \
      git push; \
      git tag "v$version"; \
      git push origin "v$version"; \
      echo "Released v$version"

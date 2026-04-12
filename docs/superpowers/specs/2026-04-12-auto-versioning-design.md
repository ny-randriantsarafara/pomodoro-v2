# Automatic Versioning, Changelog, and Tagging

**Date**: 2026-04-12
**Status**: Approved

## Overview

Automate semantic versioning, git tagging, and changelog generation for the Rhythm app. Every push to `main` (direct or squash-merged PR) produces a version bump, a git tag, a GitHub Release with auto-generated notes, and triggers TestFlight deploys with the correct app version.

## Requirements

- Version bumps are derived from **conventional commit messages** on the head commit
- PR titles must follow conventional commit format (enforced by a CI check), since squash-merge uses the PR title as the commit message
- Changelog lives exclusively in **GitHub Releases** (no `CHANGELOG.md` file)
- Version is derived from **git tags at build time** — `pubspec.yaml` is not updated by CI
- Deploy workflows trigger on **tag creation** instead of CI completion
- Starting baseline: `v1.0.0` (matches existing App Store Connect state)
- Tag format: `vMAJOR.MINOR.PATCH`

## Bump Rules

| Signal | Bump |
|--------|------|
| `BREAKING CHANGE` in commit body or `!` after type (e.g. `feat!:`) | major |
| `feat:` or `feat(scope):` | minor |
| Everything else (`fix:`, `ci:`, `chore:`, `test:`, `docs:`, `refactor:`, `perf:`, `build:`, `style:`) | patch |

If the commit message doesn't match any conventional prefix, it defaults to **patch**.

## Architecture

### Pipeline flow

```
push to main
    |
    v
CI workflow (.github/workflows/ci.yml)  -- unchanged
    |
    v  (on success, main branch only)
Version workflow (.github/workflows/version.yml)  -- NEW
    |
    |- parse head commit message
    |- determine bump level (major/minor/patch)
    |- read latest v* tag
    |- compute new version
    |- create + push annotated git tag
    |- create GitHub Release with --generate-notes
    |
    v  (tag push: v*)
Deploy workflows  -- MODIFIED trigger
    |- deploy-testflight.yml (iOS)
    |- deploy-macos-testflight.yml (macOS)
    |
    |- extract version from GITHUB_REF_NAME
    |- pass FLUTTER_BUILD_NAME to Fastlane
    |- Fastlane passes --build-name to Flutter build
```

### PR title validation flow

```
PR opened/edited/synchronized
    |
    v
PR title check (.github/workflows/pr-title.yml)  -- NEW
    |
    |- regex: ^(feat|fix|chore|ci|docs|test|refactor|perf|build|style)(\(.+\))?!?: .+
    |- pass/fail status check (blocks merge on failure)
```

## Files Changed

### New files

#### `.github/workflows/pr-title.yml`

- Triggers on `pull_request: [opened, edited, synchronize]`
- Single job with a shell step that validates the PR title against the conventional commit regex
- Fails the check if the title doesn't match, blocking merge

#### `.github/workflows/version.yml`

- Triggers on `workflow_run: [CI]` completed on `main`
- Permissions: `contents: write`
- Steps:
  1. Checkout with `fetch-depth: 0` (needs full tag history)
  2. Read head commit message from the triggering push
  3. Parse conventional commit prefix to determine bump level
  4. Read latest `v*` tag via `git describe --tags --match 'v*' --abbrev=0`, fall back to `v1.0.0` if none exists
  5. Bump the appropriate version segment, reset lower segments
  6. Create annotated git tag and push to origin
  7. Create GitHub Release via `gh release create` with `--generate-notes`

### Modified files

#### `.github/workflows/deploy-testflight.yml`

- Change trigger from `workflow_run: [CI]` to `push: tags: ['v*']`
- Keep `workflow_dispatch` for manual triggers
- Add step to extract version from tag: `VERSION="${GITHUB_REF_NAME#v}"`
- Pass `FLUTTER_BUILD_NAME` environment variable to the deploy step

#### `.github/workflows/deploy-macos-testflight.yml`

- Same changes as `deploy-testflight.yml`

#### `fastlane/Fastfile`

- Add `resolved_build_name` helper that reads `ENV["FLUTTER_BUILD_NAME"]`
- When set, pass `--build-name` via `xcargs` to the Flutter build alongside the existing build number
- When not set (local/manual builds), fall back to whatever is in `pubspec.yaml`

### Unchanged files

- `.github/workflows/ci.yml` — no changes
- `.github/workflows/deploy-supabase.yml` — no changes, stays triggered on push to `main`
- `pubspec.yaml` — not updated by CI; version derived from tags at build time

## One-time Setup

Tag the current `main` HEAD as the baseline before merging the automation:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Edge Cases

- **No conventional prefix in commit**: defaults to patch bump
- **No existing tags**: falls back to `v1.0.0` as baseline
- **Manual workflow_dispatch on deploy**: `GITHUB_REF_NAME` will be a branch name, not a tag. The `resolved_build_name` helper detects this (no `v` prefix) and falls back to `pubspec.yaml` version
- **Multiple commits in a direct push**: only the head commit message is parsed (direct pushes should be single commits in practice)
- **CI failure on main**: version workflow doesn't run (gated on CI success)

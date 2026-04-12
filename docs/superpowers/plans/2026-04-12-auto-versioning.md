# Auto-Versioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate semantic versioning, git tagging, GitHub Releases, and tag-triggered TestFlight deploys for the Rhythm app.

**Architecture:** A new version workflow runs after CI on `main`, parses the head commit for conventional commit type, bumps the latest `v*` tag accordingly, creates a GitHub Release, and pushes the tag. Deploy workflows switch from CI-triggered to tag-triggered, reading the version from the tag at build time. A PR title lint workflow enforces conventional commits at the PR gate.

**Tech Stack:** GitHub Actions, shell scripting (bash), Fastlane (Ruby), `gh` CLI

**Spec:** `docs/superpowers/specs/2026-04-12-auto-versioning-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `.github/workflows/pr-title.yml` | Create | Validate PR titles match conventional commit format |
| `.github/workflows/version.yml` | Create | Parse commit, bump version, create tag + GitHub Release |
| `.github/workflows/deploy-testflight.yml` | Modify | Switch trigger to `v*` tags, pass version to Fastlane |
| `.github/workflows/deploy-macos-testflight.yml` | Modify | Switch trigger to `v*` tags, pass version to Fastlane |
| `fastlane/Fastfile` | Modify | Accept `FLUTTER_BUILD_NAME` and pass `--build-name` to Flutter |
| `.github/workflows/ci.yml` | Modify | Exclude tag pushes to avoid unnecessary CI runs on `v*` tags |

---

### Task 1: Create PR title validation workflow

**Files:**
- Create: `.github/workflows/pr-title.yml`

- [ ] **Step 1: Create the workflow file**

```yaml
name: PR Title

on:
  pull_request:
    types: [opened, edited, synchronize]

jobs:
  lint:
    name: Validate conventional commit title
    runs-on: ubuntu-latest
    steps:
      - name: Check PR title
        env:
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: |
          PATTERN='^(feat|fix|chore|ci|docs|test|refactor|perf|build|style)(\(.+\))?!?: .+'
          if [[ ! "$PR_TITLE" =~ $PATTERN ]]; then
            echo "::error::PR title does not follow conventional commits format."
            echo ""
            echo "Expected: <type>(<optional scope>): <description>"
            echo "Types: feat, fix, chore, ci, docs, test, refactor, perf, build, style"
            echo ""
            echo "Got: $PR_TITLE"
            exit 1
          fi
          echo "PR title is valid: $PR_TITLE"
```

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/pr-title.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/pr-title.yml
git commit -m "ci: add PR title conventional commit validation"
```

---

### Task 2: Create the version bump workflow

**Files:**
- Create: `.github/workflows/version.yml`

- [ ] **Step 1: Create the workflow file**

```yaml
name: Version

on:
  workflow_run:
    workflows: [CI]
    types: [completed]
    branches: [main]

jobs:
  version:
    name: Bump version & release
    if: github.event.workflow_run.conclusion == 'success'
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.workflow_run.head_sha }}
          fetch-depth: 0

      - name: Get commit message
        id: commit
        run: |
          MSG=$(git log -1 --format='%s' "${{ github.event.workflow_run.head_sha }}")
          BODY=$(git log -1 --format='%b' "${{ github.event.workflow_run.head_sha }}")
          echo "message=$MSG" >> "$GITHUB_OUTPUT"
          echo "body<<EOF" >> "$GITHUB_OUTPUT"
          echo "$BODY" >> "$GITHUB_OUTPUT"
          echo "EOF" >> "$GITHUB_OUTPUT"

      - name: Determine bump level
        id: bump
        env:
          COMMIT_MSG: ${{ steps.commit.outputs.message }}
          COMMIT_BODY: ${{ steps.commit.outputs.body }}
        run: |
          # Check for breaking change
          if echo "$COMMIT_BODY" | grep -qi "BREAKING CHANGE"; then
            echo "level=major" >> "$GITHUB_OUTPUT"
            exit 0
          fi

          # Extract type from conventional commit prefix
          TYPE=$(echo "$COMMIT_MSG" | sed -n 's/^\([a-z]*\)\(([^)]*)\)\?!\?:.*/\1/p')
          BANG=$(echo "$COMMIT_MSG" | sed -n 's/^[a-z]*\(([^)]*)\)\?\(!\)\?:.*/\2/p')

          if [[ "$BANG" == "!" ]]; then
            echo "level=major" >> "$GITHUB_OUTPUT"
          elif [[ "$TYPE" == "feat" ]]; then
            echo "level=minor" >> "$GITHUB_OUTPUT"
          else
            echo "level=patch" >> "$GITHUB_OUTPUT"
          fi

      - name: Compute new version
        id: version
        run: |
          # Get latest tag or fall back to v1.0.0
          if LATEST=$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null); then
            echo "Found latest tag: $LATEST"
          else
            LATEST="v1.0.0"
            echo "No tags found, using baseline: $LATEST"
          fi

          # Strip v prefix and split
          VERSION="${LATEST#v}"
          IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

          LEVEL="${{ steps.bump.outputs.level }}"
          case "$LEVEL" in
            major)
              MAJOR=$((MAJOR + 1))
              MINOR=0
              PATCH=0
              ;;
            minor)
              MINOR=$((MINOR + 1))
              PATCH=0
              ;;
            patch)
              PATCH=$((PATCH + 1))
              ;;
          esac

          NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
          echo "new_tag=$NEW_TAG" >> "$GITHUB_OUTPUT"
          echo "Bump: $LEVEL — $LATEST -> $NEW_TAG"

      - name: Create tag and release
        env:
          GH_TOKEN: ${{ github.token }}
          NEW_TAG: ${{ steps.version.outputs.new_tag }}
          SHA: ${{ github.event.workflow_run.head_sha }}
        run: |
          git tag -a "$NEW_TAG" "$SHA" -m "Release $NEW_TAG"
          git push origin "$NEW_TAG"
          gh release create "$NEW_TAG" \
            --target "$SHA" \
            --title "$NEW_TAG" \
            --generate-notes
```

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/version.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/version.yml
git commit -m "ci: add automatic version bump and release workflow"
```

---

### Task 3: Switch iOS deploy workflow to tag trigger

**Files:**
- Modify: `.github/workflows/deploy-testflight.yml`

- [ ] **Step 1: Update the trigger and add version extraction**

Replace the entire file content with:

```yaml
name: Deploy to TestFlight

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  deploy:
    name: Build & Upload to TestFlight
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - name: Extract version from tag
        if: startsWith(github.ref, 'refs/tags/v')
        run: echo "FLUTTER_BUILD_NAME=${GITHUB_REF_NAME#v}" >> "$GITHUB_ENV"

      - name: Select Xcode 26
        run: sudo xcode-select -s /Applications/Xcode_26.3.app/Contents/Developer

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.2"
          bundler-cache: true

      - name: Setup
        run: make setup

      - name: Setup SSH key for Match
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.MATCH_GIT_PRIVATE_KEY }}

      - name: Sync signing
        env:
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: make sync-signing

      - name: Deploy to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FLUTTER_BUILD_NAME: ${{ env.FLUTTER_BUILD_NAME }}
        run: make deploy-testflight
```

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-testflight.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy-testflight.yml
git commit -m "ci: switch iOS deploy trigger from CI to tag push"
```

---

### Task 4: Switch macOS deploy workflow to tag trigger

**Files:**
- Modify: `.github/workflows/deploy-macos-testflight.yml`

- [ ] **Step 1: Update the trigger and add version extraction**

Replace the entire file content with:

```yaml
name: Deploy macOS to TestFlight

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  deploy:
    name: Build & Upload macOS to TestFlight
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - name: Extract version from tag
        if: startsWith(github.ref, 'refs/tags/v')
        run: echo "FLUTTER_BUILD_NAME=${GITHUB_REF_NAME#v}" >> "$GITHUB_ENV"

      - name: Select Xcode 26
        run: sudo xcode-select -s /Applications/Xcode_26.3.app/Contents/Developer

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.2"
          bundler-cache: true

      - name: Setup
        run: make setup

      - name: Setup SSH key for Match
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.MATCH_GIT_PRIVATE_KEY }}

      - name: Deploy macOS to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FLUTTER_BUILD_NAME: ${{ env.FLUTTER_BUILD_NAME }}
        run: make deploy-macos-testflight
```

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-macos-testflight.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy-macos-testflight.yml
git commit -m "ci: switch macOS deploy trigger from CI to tag push"
```

---

### Task 5: Update Fastfile to accept build name from environment

**Files:**
- Modify: `fastlane/Fastfile`

- [ ] **Step 1: Add the `resolved_build_name` helper**

After the existing `resolved_macos_build_number` function (line 19), add:

```ruby
def resolved_build_name
  first_present_env("FLUTTER_BUILD_NAME")
end
```

- [ ] **Step 2: Update `flutter_xcargs` to include build name**

Replace the existing `flutter_xcargs` function (lines 21-26) with:

```ruby
def flutter_xcargs
  parts = []

  build_number = first_present_env("FLUTTER_BUILD_NUMBER")
  parts << "FLUTTER_BUILD_NUMBER=#{build_number.shellescape}" if build_number

  build_name = resolved_build_name
  parts << "FLUTTER_BUILD_NAME=#{build_name.shellescape}" if build_name

  parts.empty? ? nil : parts.join(" ")
end
```

- [ ] **Step 3: Verify Fastfile Ruby syntax**

Run: `ruby -c fastlane/Fastfile`
Expected: `Syntax OK`

- [ ] **Step 4: Commit**

```bash
git add fastlane/Fastfile
git commit -m "feat(ci): pass build name from git tag to Flutter build"
```

---

### Task 6: Exclude tag pushes from CI workflow

**Files:**
- Modify: `.github/workflows/ci.yml`

The CI workflow currently triggers on all `push` events, including tag pushes. When the version workflow creates a `v*` tag, this would trigger an unnecessary CI run. Exclude tags to avoid wasting CI minutes.

- [ ] **Step 1: Add tag exclusion to CI trigger**

Change the `on` block from:

```yaml
on:
  push:
```

to:

```yaml
on:
  push:
    tags-ignore: ['**']
```

This keeps CI running on all branch pushes but skips tag pushes entirely.

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: exclude tag pushes from CI workflow"
```

---

### Task 7: Create baseline tag and verify

- [ ] **Step 1: Create the v1.0.0 baseline tag**

```bash
git tag v1.0.0
git push origin v1.0.0
```

- [ ] **Step 2: Verify the tag exists**

Run: `git tag -l 'v*'`
Expected: `v1.0.0`

- [ ] **Step 3: Verify the full pipeline chain**

Manually review the trigger chain is correct:
1. `ci.yml` triggers on `push` with `tags-ignore: ['**']` — runs on all branch pushes, skips tag pushes
2. `version.yml` triggers on `workflow_run: [CI]` completed on `main` — creates tag
3. `deploy-testflight.yml` triggers on `push: tags: ['v*']` — deploys iOS
4. `deploy-macos-testflight.yml` triggers on `push: tags: ['v*']` — deploys macOS
5. `pr-title.yml` triggers on `pull_request` events — validates title

Confirm no circular triggers exist: tag push skips CI (via `tags-ignore`), so the version workflow never re-fires.

- [ ] **Step 4: Push all changes and verify workflows appear on GitHub**

```bash
git push origin main
```

Check the Actions tab on GitHub to confirm all workflows are listed.

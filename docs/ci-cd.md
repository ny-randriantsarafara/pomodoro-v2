# CI/CD

Rhythm uses a **Makefile** as the single entry point for automation. The same targets work locally and on GitHub Actions.

## Principles

- **Makefile is the interface.** Both humans and CI call `make <target>`. No workflow-only logic.
- **Fastlane handles Apple.** Building, signing, and TestFlight upload go through Fastlane lanes.
- **Two independent pipelines.** Apple and Supabase deploy separately — different triggers, different runners.
- **No `if CI` conditionals.** Tools resolve credentials from the environment transparently.

## Prerequisites

- Flutter SDK (stable channel)
- Ruby 3.2+ and Bundler
- CocoaPods (`pod`)
- Supabase CLI (`brew install supabase/tap/supabase`)
- Xcode with command-line tools

## Quick start

```bash
make setup              # Install Flutter deps + iOS pods + Fastlane
make setup-fastlane     # Interactive — generates Appfile + Matchfile
make sync-signing       # Create/fetch signing certs via Match
```

## Available targets

| Target | Description |
|--------|------------|
| `make help` | List all targets |
| `make setup` | Install Flutter deps + iOS pods + Fastlane |
| `make setup-fastlane` | Generate Appfile + Matchfile interactively |
| `make analyze` | Run Flutter static analysis |
| `make test` | Run Flutter tests |
| `make ci` | Run analyze + test |
| `make build-ios` | Build iOS IPA |
| `make build-macos` | Build macOS app |
| `make deploy-testflight` | Build + upload iOS to TestFlight |
| `make deploy-macos-testflight` | Build + upload macOS to TestFlight |
| `make deploy-supabase` | Push migrations + deploy edge functions |
| `make sync-signing` | Sync iOS signing certs/profiles via Match |
| `make sync-signing-macos` | Sync macOS signing certs/profiles via Match |

## One-time setup

### 1. Create a private certificates repo

Create a private repo on GitHub (e.g. `your-user/ios-certificates`). This stores encrypted signing certificates and provisioning profiles managed by Fastlane Match.

### 2. Install dependencies

```bash
make setup
```

### 3. Configure Fastlane

```bash
make setup-fastlane
```

You will be prompted for:
- **Apple ID**: your Apple Developer email
- **Team ID**: your Apple Developer team ID (find it at [developer.apple.com/account](https://developer.apple.com/account) under Membership)
- **Bundle ID**: defaults to `com.nyhasinavalona.rhythm`
- **Match git URL**: SSH URL of the private certificates repo (e.g. `git@github.com:you/ios-certificates.git`)

This generates `fastlane/Appfile` and `fastlane/Matchfile` (both gitignored — they contain credentials).

### 4. Initialize signing

```bash
make sync-signing
```

First run creates certificates and provisioning profiles, encrypts them, and pushes to the certificates repo. You will be asked to set a passphrase — this becomes the `MATCH_PASSWORD` secret.

### 5. Create App Store Connect API key

1. Go to [App Store Connect > Users and Access > Keys](https://appstoreconnect.apple.com/access/api)
2. Create a new key with "App Manager" role
3. Note the **Key ID** and **Issuer ID**: BKW267S59W and d5c120e1-2643-4429-8513-ca705f7717ab
4. Download the `.p8` file
5. Base64-encode it: `base64 -i AuthKey_XXXX.p8`

### 6. Configure GitHub Actions secrets

Go to your repo > Settings > Secrets and variables > Actions. Add:

| Secret | Value |
|--------|-------|
| `MATCH_PASSWORD` | The passphrase you set in step 4 |
| `MATCH_GIT_PRIVATE_KEY` | SSH private key with access to the certificates repo |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from step 5 |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step 5 |
| `APP_STORE_CONNECT_API_KEY` | Base64-encoded `.p8` content from step 5 |
| `SUPABASE_ACCESS_TOKEN` | From `supabase token` or dashboard |
| `SUPABASE_PROJECT_ID` | Your Supabase project reference ID |

Note: the workflow maps the `APP_STORE_CONNECT_API_KEY` secret to an internal env var named `APP_STORE_CONNECT_API_KEY_CONTENT` before calling Fastlane. This avoids Fastlane's reserved `APP_STORE_CONNECT_API_KEY` env name colliding with `match`'s `api_key` option.

### 7. Push

CI runs on every push. TestFlight and Supabase deploy on merges to `main` or via manual trigger in the Actions tab.

## Pipelines

### CI (`ci.yml`)
- **Trigger:** every push, all branches
- **Runner:** `macos-latest`
- **Steps:** analyze, test, build iOS, build macOS

### TestFlight (`deploy-testflight.yml`)
- **Trigger:** push to `main`, manual
- **Runner:** `macos-latest`
- **Steps:** sync signing, build iOS, upload to TestFlight
- **Build number:** Fastlane auto-sets a unique iOS build number for uploads. It prefers `IOS_BUILD_NUMBER`, then `GITHUB_RUN_NUMBER` on CI, and falls back to a UTC timestamp for local/manual runs.

### macOS TestFlight (`deploy-macos-testflight.yml`)
- **Trigger:** push to `main`, manual
- **Runner:** `macos-latest`
- **Steps:** sync macOS signing, build macOS, upload to TestFlight
- **Build number:** Same pattern as iOS. Prefers `MACOS_BUILD_NUMBER`, then `GITHUB_RUN_NUMBER` on CI, and falls back to a UTC timestamp for local/manual runs.

### Supabase (`deploy-supabase.yml`)
- **Trigger:** push to `main`, manual
- **Runner:** `ubuntu-latest`
- **Steps:** link project, push migrations, deploy edge functions

## Local vs CI parity

| Concern | Local | CI |
|---------|-------|-----|
| Code signing | Keychain | Fastlane `setup_ci` creates an unlocked temporary keychain, then Match imports signing assets there |
| Apple auth (TestFlight) | Apple session / API key in env | API key from GitHub secrets |
| Supabase auth | `supabase login` session | `SUPABASE_ACCESS_TOKEN` env var |
| SSH for Match repo | Your SSH key | `MATCH_GIT_PRIVATE_KEY` injected |
| Flutter SDK | Already installed | `subosito/flutter-action` |
| Ruby / Fastlane | `bundle install` via `make setup` | Same |

## Adding a new signing profile

If you add a new app target or bundle ID:

1. Update `fastlane/Appfile` with the new identifier (or re-run `make setup-fastlane`)
2. Run `make sync-signing` to generate profiles for the new ID
3. Update the Fastfile lanes if needed

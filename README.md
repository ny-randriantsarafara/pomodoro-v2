# Rhythm

A task-centered Pomodoro focus app built in Flutter. Tasks are the main unit; projects are optional grouping. Focus and break are full-screen flows so the shift into (and out of) deep work feels intentional.

This repository’s package name is **`rhythm`** (see `pubspec.yaml`).

## Stack

| Area | Choice |
|------|--------|
| UI | Flutter (Material 3 via `lib/theme/`) |
| App state | `ChangeNotifier` + **Riverpod** (`AppStore`, `lib/store/`) |
| Routing | **go_router** — shell routes + immersive timer routes |
| Icons | lucide_icons |
| Dates / copy | intl |
| Typography | **Inter** + **JetBrains Mono** (bundled under `assets/fonts/`) |

## Run / test

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

Fonts are declared in `pubspec.yaml`; ensure the files listed there exist under `assets/fonts/`. The implementation plan describes the expected filenames (`docs/plans/2026-04-03-rhythm-flutter-implementation.md`, preflight section).

## Routes

| Path | Notes |
|------|--------|
| `/` | Home (today, tasks, composer) |
| `/history` | Rhythm / history stats and session log |
| `/auth` | Sign in / sign up (mock auth) |
| `/focus/:taskId` | Immersive focus timer; optional query `preset` (minutes, default `25`) |
| `/break/:taskId` | Break flow; queries `mins` (default `5`), `completed` (`true` / absent) |

Main chrome lives in a **shell** (desktop header or mobile header + bottom nav). Focus and break sit **outside** the shell with a fade transition.

## Data layer

Repositories (`lib/repositories/`) are **interfaces** with **in-memory** implementations so persistence (API, local DB, etc.) can be swapped without rewriting feature code. `AppStore` coordinates tasks, projects, sessions, and presets.

## Project layout

High level (feature-based):

- `lib/theme/` — design tokens (color, type, spacing, motion, radii, shadows)
- `lib/models/` — `Project`, `Task`, `Session`
- `lib/store/` — global state + Riverpod providers
- `lib/router/` — `go_router` configuration
- `lib/features/` — `layout`, `home`, `focus`, `break_timer`, `history`, `auth`
- `lib/shared/` — reusable widgets and utilities

A fuller folder map and product principles live in the design doc below.

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/plans/2026-04-03-rhythm-flutter-rebuild-design.md](docs/plans/2026-04-03-rhythm-flutter-rebuild-design.md) | Product intent, architecture, chunk boundaries |
| [docs/plans/2026-04-03-rhythm-flutter-implementation.md](docs/plans/2026-04-03-rhythm-flutter-implementation.md) | Implementation plan (tasks, verification, UI specs) |

For general Flutter help: [Flutter documentation](https://docs.flutter.dev/).

# Session Alerts, Settings, and Privacy Design

## Goal

Add cross-platform session-complete alerts for both focus and break timers, with different sounds per completion type, a dedicated Settings page for alert preferences and account actions, and a public Privacy Policy page on web for App Store Connect review.

## Constraints and agreed scope

- Native platforms should support reliable session-complete alerts even when the app is backgrounded.
- Web support is considered successful while the app tab is open or backgrounded; closed-browser reliability is out of scope.
- Both focus and break completions should alert, with different sounds for each.
- v1 uses global toggles for notifications and sound.
- Account actions move into a dedicated Settings page.
- The implementation should use minimal refactor, only where timer completion data is already being passed.

## Approaches considered

### 1. Small alert domain + thin platform adapters (recommended)
Create a small alert domain, a settings repository, and platform adapters for notifications and sound. Keep timer pages responsible for timer lifecycle and navigation, but delegate alert decisions and delivery to a coordinator.

**Why recommended:** clean separation without a broad rewrite, easy to test, minimal refactor in the current focus and break flows.

### 2. Direct wiring inside timer pages
Call notification and sound APIs directly from `FocusTimerPage` and `BreakTimerPage` and add a simple Settings page.

**Why not chosen:** fast, but mixes UI state with platform concerns, duplicates logic, and makes future changes harder.

### 3. Shared timer engine/state machine
Centralize timer lifecycle, completion, and alert orchestration in a reusable engine.

**Why not chosen:** architecturally nice, but larger than the requested refactor budget.

## Architecture

### New seams

1. **Alert domain**
   - Pure types for alert events such as `focusCompleted` and `breakCompleted`
   - Pure settings model with:
     - notifications enabled
     - sound enabled
   - Pure decision helpers that compute whether notification and/or sound should be attempted for a given alert event

2. **Alert settings repository**
   - Small `SharedPreferences`-backed repository for loading and saving alert preferences
   - Independent from timer widgets and router concerns

3. **Platform adapters**
   - `NotificationAdapter` for platform notification behavior
   - `SoundAdapter` for bundled focus/break completion sounds
   - Web notification support uses the browser Notification API through a dedicated web adapter rather than pretending native plugin behavior exists on web

4. **Session alert coordinator**
   - Thin application layer called by timer flows
   - Lifecycle-oriented API rather than widget-owned platform logic:
     - `onSessionStarted(type, endsAt)`
     - `onSessionCancelledOrReset()`
     - `onSessionCompleted(type)`
   - Optional `reconcile()` on app start/resume if needed later

5. **Settings and privacy surfaces**
   - New `/settings` route inside the app
   - New public `/privacy` route with no auth requirement
   - Existing header account entry becomes navigation to Settings rather than inline sign-out/delete actions

### Important reliability refinement

For reliable native alerts, local notifications should be **scheduled when a focus or break session starts** and **cancelled if the session is paused, abandoned, reset, or otherwise invalidated**. Completion-time code alone is not enough for background reliability because app code may not be executing at the exact end moment.

Completion handlers still matter, but mainly for:
- session persistence
- navigation
- in-app sound when the app is active
- notification cleanup / foreground fallback behavior

## Components and data flow

### Settings model

For v1, the settings object stays intentionally small:

- `notificationsEnabled`
- `soundEnabled`

Focus and break sounds differ internally by alert type; separate user-configurable sound selection is out of scope.

### Session start flow

#### Focus start
1. User starts a focus session from the preset picker.
2. The focus page knows the planned end time from preset minutes.
3. The session alert coordinator is called with `focus` and `endsAt`.
4. If notifications are enabled and the platform supports scheduling, a local notification is scheduled using focus-complete messaging/sound mapping.
5. If the platform cannot schedule, the adapter no-ops and logs capability limits.

#### Break start
1. Focus completion navigates into break with the selected break duration.
2. Break timer initialization calls the coordinator with `break` and `endsAt`.
3. The coordinator schedules the break-complete notification using break-specific copy/sound mapping.

### Session cancellation/reset flow

- If a timer is abandoned, paused in a way that invalidates the scheduled end time, or restarted, the coordinator cancels the outstanding scheduled notification.
- This prevents stale alerts after the user leaves the flow early.

### Session completion flow

#### Focus completion
1. `FocusTimerPage` persists the completed session exactly as it does now.
2. The page calls `onSessionCompleted(focus)`.
3. The coordinator reads current settings.
4. Pure decision helpers decide whether in-app sound should play and whether any foreground notification cleanup is needed.
5. The platform adapters execute best-effort foreground behavior.
6. UI navigates to the break route.

#### Break completion
1. `BreakTimerPage` reaches zero.
2. The page calls `onSessionCompleted(break)`.
3. The coordinator performs the same decision flow with break-specific mapping.
4. UI navigates home.

### Separation of responsibilities

- **Timer pages:** timer lifecycle, persistence, navigation, and calling coordinator hooks
- **Coordinator:** application glue between timer lifecycle and platform adapters
- **Pure alert rules:** testable behavior decisions from event + settings + capabilities
- **Adapters:** notification scheduling/cancellation and sound playback
- **Settings repository/providers:** alert preference persistence and access

## Error handling and platform behavior

### Notification behavior

- Native platforms attempt scheduled local notifications when a session starts.
- If notification permission is denied or unavailable:
  - scheduling is skipped
  - timer flow still works
  - sound can still be attempted when app code is active
- Web notifications are best-effort while the app/tab remains alive or backgrounded.

### Sound behavior

- Focus completion uses one bundled sound.
- Break completion uses a different bundled sound.
- Sound playback is best-effort and never blocks persistence or navigation.
- Web audio depends on prior user interaction/autoplay unlock; timer start counts as the expected unlock point.

### Platform caveats

- **Android:** focus and break notification sounds may require distinct notification channels.
- **iOS/macOS:** notification permission and bundled custom sounds are supported patterns.
- **Windows/Linux/macOS desktop:** notification delivery should work, but perfect OS-level sound parity is not guaranteed; promise notification delivery plus in-app sound where possible.
- **Web:** do not promise closed-browser behavior.

### Failure policy

Alert failures are non-fatal:
- session persistence remains primary
- route transitions continue
- failures are logged
- users should never get stuck because alerts fail

### Permission UX

For v1:
- do not prompt on first app launch
- request notification permission when the user enables notifications or when alert scheduling is first required
- reflect denied/unavailable state in Settings copy

## Settings and privacy UI

### Settings page

v1 Settings includes:
- notifications toggle
- sound toggle
- privacy policy link
- account section with sign out and delete account actions

The current Account popup in desktop/mobile headers becomes a simpler entry point to Settings.

### Privacy policy page

The public privacy page should truthfully describe current behavior:
- authentication methods used
- tasks, projects, and sessions stored for signed-in users
- locally stored app preferences
- local notifications if enabled
- account deletion availability
- how policy updates will be communicated

The page should be accessible as a public route on web and linked from Settings.

## Testing strategy

### Pure logic tests

Add unit tests for:
- alert decision rules
- settings defaults and serialization
- capability/permission-based no-op behavior

### Coordinator tests

Add tests with fake adapters/repositories to verify:
- session start schedules the correct alert kind
- cancellation removes scheduled alerts
- completion plays the correct sound kind when enabled
- failures are logged and do not throw into UI flows

### Widget tests

Keep UI tests light:
- Settings page renders current toggle state
- toggles persist changes
- privacy link is visible
- account actions are present in Settings
- headers route to Settings instead of exposing inline account actions

### Route tests

Cover:
- `/settings`
- `/privacy`
- privacy page is reachable without auth

### Manual verification

Manual checks will still be needed for:
- native background notification delivery
- platform permission prompts
- web background behavior while tab remains open
- different focus/break sounds

## Documentation and artifact disposition

- **Temporary artifact:** this design doc in `docs/plans/`
- **Promote if validated during implementation:**
  - `README.md` for Settings and privacy route visibility
  - a durable doc if alert platform caveats prove important for future work
- **Delete if not durable:** this design doc if it no longer adds value after implementation and follow-up documentation updates are complete

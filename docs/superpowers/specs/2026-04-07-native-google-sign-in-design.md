# Native Google Sign-In for iOS and macOS

**Date:** 2026-04-07
**Status:** Approved

## Problem

When signing in with Google via `signInWithOAuth`, the OAuth flow opens Safari externally. After authentication, the deep link redirect (`io.supabase.rhythm://login-callback`) brings the user back to the app, but the Safari tab/window stays open on both iOS and macOS.

## Solution

Replace the browser-based `signInWithOAuth` flow with a native Google Sign-In flow using the `google_sign_in` package + Supabase `signInWithIdToken`.

## Auth Flow

**Current:**
User taps Google -> `signInWithOAuth` -> Safari opens -> user authenticates -> deep link redirect -> app resumes -> Safari stays open

**New:**
User taps Google -> `google_sign_in` native UI (system sheet) -> user authenticates -> ID token returned -> `signInWithIdToken` on Supabase -> auth state changes -> router redirects to home -> no browser involved

## Code Changes

### Dependencies

Add `google_sign_in` to `pubspec.yaml`.

### Auth Repository Interface

`lib/repositories/auth_repository.dart` -- no change. The `signInWithGoogle()` signature stays the same. Callers are unaffected.

### Supabase Auth Repository

`lib/repositories/supabase_auth_repository.dart` -- main change. `signInWithGoogle()` will:

1. Create a `GoogleSignIn` instance with the web/server client ID and desired scopes
2. Call `googleSignIn.signIn()` to trigger the native sign-in UI
3. Extract `idToken` and `accessToken` from the returned `GoogleSignInAuthentication`
4. Call `_client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: ..., accessToken: ...)` to authenticate with Supabase

If `signIn()` returns `null` (user cancelled), return gracefully without error.

### Auth Page

`lib/features/auth/auth_page.dart` -- no changes. Already calls `authRepo.signInWithGoogle()`.

### macOS Caveat

`google_sign_in` supports macOS through the `google_sign_in_ios` federated plugin (shared Apple platform SDK). If this doesn't work out-of-the-box on macOS, fallback to `flutter_web_auth_2` (ASWebAuthenticationSession) for macOS only.

## Platform Configuration

### Google Cloud Console (one-time)

- Use the same Google Cloud project linked to the Supabase Google auth provider
- The **Web client ID** already exists (used by Supabase) -- this becomes the `serverClientId`
- Create an **iOS OAuth client ID** (needs iOS bundle ID)
- Create a **macOS OAuth client ID** (needs macOS bundle ID)

### iOS (`ios/Runner/Info.plist`)

- Add the **reversed iOS client ID** as a URL scheme (e.g., `com.googleusercontent.apps.XXXX`)
- Keep existing `io.supabase.rhythm` scheme (needed for magic link)

### macOS (`macos/Runner/Info.plist`)

- Add the **reversed macOS client ID** as a URL scheme
- Ensure `com.apple.security.network.client` entitlement is present

### GoogleService-Info.plist

- Download from Google Cloud Console
- Add to both iOS and macOS Runner targets
- The `google_sign_in` SDK reads configuration from this file on Apple platforms

## Error Handling

No new error handling patterns. The existing `try/catch` in `_handleGoogle()` on the auth page catches and logs all errors. The `google_sign_in` package throws standard exceptions (user cancellation, network errors) caught by the same block.

User cancellation: `googleSignIn.signIn()` returns `null` instead of throwing. The repository handles this by returning early.

## Testing

- `AuthRepository` interface unchanged -- all widget tests with mocked auth repos continue to work
- `SupabaseAuthRepository.signInWithGoogle()` is an integration concern (Google SDK + Supabase) -- verified through manual testing on iOS and macOS devices
- No new unit tests needed

## Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `google_sign_in` dependency |
| `lib/repositories/supabase_auth_repository.dart` | Replace `signInWithOAuth` with native `GoogleSignIn` + `signInWithIdToken` |
| `ios/Runner/Info.plist` | Add reversed Google client ID URL scheme |
| `macos/Runner/Info.plist` | Add reversed Google client ID URL scheme |
| iOS Runner target | Add `GoogleService-Info.plist` |
| macOS Runner target | Add `GoogleService-Info.plist` |

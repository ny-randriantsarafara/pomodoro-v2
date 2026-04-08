# Native Google Sign-In Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace browser-based Google OAuth with native Google Sign-In so the sign-in page auto-dismisses on iOS and macOS.

**Architecture:** Use the `google_sign_in` package for native credentials, then pass the ID token to Supabase `signInWithIdToken`. The auth repository interface stays unchanged -- only the `SupabaseAuthRepository` implementation changes. The Google web client ID is passed via `--dart-define` following the existing pattern for Supabase credentials.

**Tech Stack:** Flutter, `google_sign_in`, `supabase_flutter`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `pubspec.yaml` | Modify | Add `google_sign_in` dependency |
| `lib/repositories/supabase_auth_repository.dart` | Modify | Replace `signInWithOAuth` with native `GoogleSignIn` + `signInWithIdToken` |
| `ios/Runner/Info.plist` | Modify | Add reversed Google client ID URL scheme |
| `macos/Runner/Info.plist` | Modify | Add reversed Google client ID URL scheme |

**Manual steps (not code -- user must do):**
- Create iOS and macOS OAuth client IDs in Google Cloud Console
- Download `GoogleService-Info.plist` for each platform and add to Xcode targets
- Note the Web client ID (already exists in Google Cloud Console if Supabase Google auth is configured)

---

### Task 1: Add `google_sign_in` dependency

**Files:**
- Modify: `pubspec.yaml:9-16`

- [ ] **Step 1: Add dependency to pubspec.yaml**

In `pubspec.yaml`, add `google_sign_in` under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  go_router: ^14.0.0
  google_sign_in: ^6.2.1
  lucide_icons: ^0.257.0
  intl: ^0.19.0
  supabase_flutter: ^2.0.0
```

- [ ] **Step 2: Install the dependency**

Run: `flutter pub get`
Expected: resolves successfully, no version conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add google_sign_in dependency"
```

---

### Task 2: Replace `signInWithOAuth` with native Google Sign-In

**Files:**
- Modify: `lib/repositories/supabase_auth_repository.dart:1-43`

- [ ] **Step 1: Verify existing tests pass before changes**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 2: Update the repository implementation**

Replace the full contents of `lib/repositories/supabase_auth_repository.dart` with:

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  static const _googleServerClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  @override
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.rhythm://login-callback',
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(serverClientId: _googleServerClientId);
    final account = await googleSignIn.signIn();
    if (account == null) return; // user cancelled

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw AuthException('Google Sign-In did not return an ID token.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  @override
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.rhythm://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;
}
```

Key changes from the original:
- Import `google_sign_in`
- `_googleServerClientId` reads the Web client ID from `--dart-define` (same pattern as Supabase URL/key in `main.dart`)
- `signInWithGoogle()` uses `GoogleSignIn.signIn()` for native credentials, then `signInWithIdToken` for Supabase auth
- Returns early if user cancels (`account == null`)
- Throws `AuthException` if no ID token (defensive, shouldn't happen in practice)
- `signInWithApple()` unchanged (separate concern)

- [ ] **Step 3: Verify existing tests still pass**

Run: `flutter test`
Expected: all tests pass. The `TestAuthRepository` in `test/helpers/test_repositories.dart` mocks the interface, so it's unaffected by the implementation change.

- [ ] **Step 4: Commit**

```bash
git add lib/repositories/supabase_auth_repository.dart
git commit -m "feat: replace Google OAuth browser flow with native sign-in"
```

---

### Task 3: Configure iOS platform

**Files:**
- Modify: `ios/Runner/Info.plist:27-37`

- [ ] **Step 1: Add reversed Google client ID URL scheme to iOS Info.plist**

In `ios/Runner/Info.plist`, add a second `dict` entry inside the existing `CFBundleURLTypes` array. The reversed client ID comes from the iOS OAuth client ID created in Google Cloud Console (format: `com.googleusercontent.apps.YOUR_IOS_CLIENT_ID`):

```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>io.supabase.rhythm</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>io.supabase.rhythm</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleURLName</key>
			<string>google-sign-in</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
			</array>
		</dict>
	</array>
```

Replace `YOUR_IOS_CLIENT_ID` with the actual reversed client ID from `GoogleService-Info.plist` (the `REVERSED_CLIENT_ID` field).

- [ ] **Step 2: Add GoogleService-Info.plist to iOS target**

This is a manual Xcode step:
1. Download `GoogleService-Info.plist` from Google Cloud Console for the iOS client ID
2. In Xcode, right-click the `Runner` folder under `ios/Runner` and select "Add Files to Runner"
3. Select the downloaded `GoogleService-Info.plist`
4. Ensure "Copy items if needed" is checked and the Runner target is selected

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/Info.plist ios/Runner/GoogleService-Info.plist
git commit -m "chore: configure iOS for native Google Sign-In"
```

---

### Task 4: Configure macOS platform

**Files:**
- Modify: `macos/Runner/Info.plist:31-41`

- [ ] **Step 1: Add reversed Google client ID URL scheme to macOS Info.plist**

In `macos/Runner/Info.plist`, add a second `dict` entry inside the existing `CFBundleURLTypes` array:

```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>io.supabase.rhythm</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>io.supabase.rhythm</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleURLName</key>
			<string>google-sign-in</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>com.googleusercontent.apps.YOUR_MACOS_CLIENT_ID</string>
			</array>
		</dict>
	</array>
```

Replace `YOUR_MACOS_CLIENT_ID` with the actual reversed client ID for the macOS OAuth client.

- [ ] **Step 2: Add GoogleService-Info.plist to macOS target**

Same manual Xcode step as iOS:
1. Download `GoogleService-Info.plist` from Google Cloud Console for the macOS client ID
2. In Xcode, add it under `macos/Runner`
3. Ensure the macOS Runner target is selected

- [ ] **Step 3: Verify macOS entitlements**

The `macos/Runner/DebugProfile.entitlements` already has `com.apple.security.network.client` set to `true` (line 9). No changes needed. Same for `macos/Runner/Release.entitlements` (line 8). Just verify they're present.

- [ ] **Step 4: Commit**

```bash
git add macos/Runner/Info.plist macos/Runner/GoogleService-Info.plist
git commit -m "chore: configure macOS for native Google Sign-In"
```

---

### Task 5: Update build/run commands

**Files:** None (documentation only)

- [ ] **Step 1: Update the dart-define flags for running the app**

The app now requires a third `--dart-define` flag. The full run command becomes:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your_web_client_id
```

The `GOOGLE_WEB_CLIENT_ID` is the **Web** OAuth 2.0 client ID from Google Cloud Console (not the iOS or macOS client ID). This is the same client ID configured in Supabase Dashboard > Authentication > Providers > Google.

---

### Task 6: Manual testing

- [ ] **Step 1: Test on iOS simulator/device**

1. Run the app on iOS with all three `--dart-define` flags
2. Tap "Continue with Google"
3. Verify: native Google sign-in sheet appears (not Safari)
4. Complete sign-in
5. Verify: sheet dismisses automatically, app navigates to home
6. Verify: no Safari tab left open

- [ ] **Step 2: Test on macOS**

1. Run the app on macOS with all three `--dart-define` flags
2. Tap "Continue with Google"
3. Verify: native sign-in dialog appears (not Safari)
4. Complete sign-in
5. Verify: dialog closes, app navigates to home
6. Verify: no Safari window left open

- [ ] **Step 3: Test cancellation**

1. Tap "Continue with Google"
2. Cancel/dismiss the sign-in sheet
3. Verify: app returns to auth page without error, no crash

- [ ] **Step 4: Verify magic link still works**

1. Enter email and tap "Send magic link"
2. Verify: magic link flow is unaffected by the changes

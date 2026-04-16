import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';
import '../shared/logging/app_logger.dart';
import 'web_helpers.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  static const _nativeRedirect = 'io.supabase.rhythm://login-callback';
  static const _nativeScheme = 'io.supabase.rhythm';

  String get _webRedirect {
    // Use actual browser origin instead of Uri.base to handle local/production correctly
    final origin = kIsWeb ? getWebOrigin() : '';
    final resolved = '$origin/auth.html';
    return resolved;
  }

  @override
  Future<void> signInWithMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: kIsWeb ? _webRedirect : _nativeRedirect,
    );
  }

  @override
  Future<void> signInWithGoogle() =>
      _signInWithOAuthProvider(OAuthProvider.google);

  @override
  Future<void> signInWithApple() =>
      _signInWithOAuthProvider(OAuthProvider.apple);

  Future<void> _signInWithOAuthProvider(OAuthProvider provider) async {
    final redirectTo = kIsWeb ? _webRedirect : _nativeRedirect;

    if (kIsWeb) {
      // On web, use Supabase's built-in OAuth redirect flow
      // This handles the full redirect cycle automatically
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo,
      );
      // The page will redirect, so code after this won't execute
      return;
    }

    // On native platforms, use FlutterWebAuth2 for custom URL scheme handling
    final res = await _client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: redirectTo,
    );

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: res.url.toString(),
      callbackUrlScheme: _nativeScheme,
    );

    final uri = Uri.parse(callbackUrl);

    final error = uri.queryParameters['error'];
    if (error != null) {
      final description =
          uri.queryParameters['error_description'] ?? error;
      AppLogger.error(
        domain: 'auth',
        event: 'oauth_error_in_callback',
        context: {'error': error, 'description': description},
      );
      throw AuthException(description);
    }

    final code = uri.queryParameters['code'];
    if (code == null) {
      AppLogger.error(
        domain: 'auth',
        event: 'oauth_no_code',
        context: {'uri': uri.toString(), 'queryParams': uri.queryParameters},
      );
      throw AuthException(
        'OAuth callback did not contain an authorization code.',
      );
    }

    await _client.auth.exchangeCodeForSession(code);

  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke(
      'delete-user',
      method: HttpMethod.post,
    );
    if (response.status != 200) {
      throw AuthException(
        'Failed to delete account (status ${response.status})',
      );
    }
    await _client.auth.signOut();
  }

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;
}

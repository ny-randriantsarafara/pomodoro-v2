import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  static const _nativeRedirect = 'io.supabase.rhythm://login-callback';
  static const _nativeScheme = 'io.supabase.rhythm';

  String get _webRedirect =>
      Uri.base.resolve('/auth.html').toString();

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

    final res = await _client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: redirectTo,
    );

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: res.url.toString(),
      callbackUrlScheme: kIsWeb ? Uri.base.scheme : _nativeScheme,
    );

    final uri = Uri.parse(callbackUrl);

    final error = uri.queryParameters['error'];
    if (error != null) {
      final description =
          uri.queryParameters['error_description'] ?? error;
      throw AuthException(description);
    }

    final code = uri.queryParameters['code'];
    if (code == null) {
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
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;
}

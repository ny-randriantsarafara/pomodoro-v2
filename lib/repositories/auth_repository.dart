import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithMagicLink(String email);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;
}

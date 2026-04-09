import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/repositories.dart';
import 'app_store.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart with actual instance');
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.onAuthStateChange;
});

/// Rebuilds downstream providers when auth state changes.
final isAuthenticatedProvider = Provider<bool>((ref) {
  ref.watch(authStateProvider);
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.currentUser != null;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return SupabaseTaskRepository(ref.watch(supabaseClientProvider));
  }
  return LocalTaskRepository(ref.watch(sharedPreferencesProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return SupabaseProjectRepository(ref.watch(supabaseClientProvider));
  }
  return LocalProjectRepository(ref.watch(sharedPreferencesProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  if (ref.watch(isAuthenticatedProvider)) {
    return SupabaseSessionRepository(ref.watch(supabaseClientProvider));
  }
  return LocalSessionRepository(ref.watch(sharedPreferencesProvider));
});

final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) {
  return AppStore(
    taskRepo: ref.watch(taskRepositoryProvider),
    projectRepo: ref.watch(projectRepositoryProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
  );
});

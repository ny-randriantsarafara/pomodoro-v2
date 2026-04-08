import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/repositories.dart';
import 'app_store.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return SupabaseTaskRepository(ref.watch(supabaseClientProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return SupabaseProjectRepository(ref.watch(supabaseClientProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SupabaseSessionRepository(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) {
  return AppStore(
    taskRepo: ref.watch(taskRepositoryProvider),
    projectRepo: ref.watch(projectRepositoryProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
  );
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.onAuthStateChange;
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'services/local_to_supabase_migration.dart';
import 'store/providers.dart';
import 'theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});

class RhythmApp extends ConsumerWidget {
  const RhythmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (prev, next) async {
      final wasSignedIn = prev?.valueOrNull?.session != null;
      final isSignedIn = next.valueOrNull?.session != null;

      if (!wasSignedIn && isSignedIn) {

        await LocalToSupabaseMigration(
          prefs: ref.read(sharedPreferencesProvider),
          client: ref.read(supabaseClientProvider),
        ).migrateIfNeeded();

        // Explicitly navigate to home after successful sign-in
        final router = ref.read(routerProvider);
        final currentLocation = router.routerDelegate.currentConfiguration.fullPath;
        if (currentLocation == '/auth') {
          router.go('/');
        }
      }

      if (isSignedIn) {
        ref.read(appStoreProvider).loadData();
      }
    });

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Rhythm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

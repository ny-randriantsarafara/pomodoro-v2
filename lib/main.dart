import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'shared/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  if (kDebugMode) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      AppLogger.debug(
        domain: 'auth',
        event: 'auth_state_changed',
        context: {
          'authEvent': event.name,
          'hasSession': session != null,
          'sessionUserId': session?.user.id,
          'currentUserId': Supabase.instance.client.auth.currentUser?.id,
        },
      );
    });
  }

  runApp(
    const ProviderScope(
      child: RhythmApp(),
    ),
  );
}

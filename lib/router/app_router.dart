import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/layout/app_shell.dart';
import '../features/home/home_page.dart';
import '../features/history/history_page.dart';
import '../features/auth/auth_page.dart';
import '../features/focus/focus_timer_page.dart';
import '../features/break_timer/break_timer_page.dart';
import '../store/providers.dart';
import '../shared/logging/app_logger.dart';

GoRouter createRouter(Ref ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authRepo.currentUser != null;
      final isOnAuth = state.matchedLocation == '/auth';

      AppLogger.debug(
        domain: 'router',
        event: 'redirect_check',
        context: {
          'isAuthenticated': isAuthenticated,
          'isOnAuth': isOnAuth,
          'matchedLocation': state.matchedLocation,
          'currentUserId': authRepo.currentUser?.id,
        },
      );

      if (isAuthenticated && isOnAuth) return '/';
      return null;
    },
    refreshListenable: _AuthNotifier(ref),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AuthPage(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/focus/:taskId',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final preset = int.tryParse(
                state.uri.queryParameters['preset'] ?? '',
              ) ??
              25;
          return CustomTransitionPage(
            child: FocusTimerPage(taskId: taskId, preset: preset),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
      GoRoute(
        path: '/break/:taskId',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final breakMinutes = int.tryParse(
                state.uri.queryParameters['mins'] ?? '',
              ) ??
              5;
          final justCompleted =
              state.uri.queryParameters['completed'] == 'true';
          return CustomTransitionPage(
            child: BreakTimerPage(
              taskId: taskId,
              breakMinutes: breakMinutes,
              justCompleted: justCompleted,
            ),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen(authStateProvider, (prev, next) {
      AppLogger.debug(
        domain: 'router',
        event: 'auth_state_changed_in_notifier',
        context: {
          'prevHasSession': prev?.valueOrNull?.session != null,
          'nextHasSession': next.valueOrNull?.session != null,
        },
      );
      notifyListeners();
    });
  }

  final Ref _ref; // ignore: unused_field
}

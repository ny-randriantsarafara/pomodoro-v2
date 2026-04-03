import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/layout/app_shell.dart';
import '../features/home/home_page.dart';
import '../features/history/history_page.dart';
import '../features/auth/auth_page.dart';
import '../features/focus/focus_timer_page.dart';
import '../features/break_timer/break_timer_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl,
                vertical: AppSpacing.xxxl,
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Privacy Policy', style: AppTypography.headingXl),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _section(
                  'What Rhythm Collects',
                  'Rhythm is a task-centered Pomodoro focus app. When you are '
                      'signed in, Rhythm stores your tasks, projects, and sessions '
                      'in a cloud database so they are available across devices. '
                      'When you are not signed in, this data is stored locally on '
                      'your device.',
                ),
                _section(
                  'Authentication',
                  'Rhythm supports sign-in via Google, Apple, and email magic '
                      'link through Supabase Auth. Rhythm does not store your '
                      'password. The only profile information retained is your '
                      'email address and authentication provider identifier.',
                ),
                _section(
                  'Local Preferences',
                  'App preferences such as alert settings (notifications and '
                      'sound toggles) are stored locally on your device using '
                      'SharedPreferences and are never transmitted to a server.',
                ),
                _section(
                  'Notifications',
                  'If you enable notifications, Rhythm schedules local '
                      'notifications on your device to alert you when focus or '
                      'break sessions complete. No notification data is sent to '
                      'external services.',
                ),
                _section(
                  'Account Deletion',
                  'You can delete your account at any time from Settings. '
                      'Deleting your account permanently removes all associated '
                      'data (tasks, projects, sessions) from the cloud database.',
                ),
                _section(
                  'Changes to This Policy',
                  'If this policy changes, the updated version will be published '
                      'at this same URL. Continued use of Rhythm after changes '
                      'constitutes acceptance of the updated policy.',
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Last updated: April 2026',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headingLg.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTypography.bodyBase.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

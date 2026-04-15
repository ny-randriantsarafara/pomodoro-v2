import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/page_entry_animation.dart';
import '../../shared/widgets/standalone_page_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _breakpoint = 768.0;

  static const _sections = [
    (
      title: 'What Rhythm Collects',
      body: 'Rhythm is a task-centered Pomodoro focus app. When you are '
          'signed in, Rhythm stores your tasks, projects, and sessions '
          'in a cloud database so they are available across devices. '
          'When you are not signed in, this data is stored locally on '
          'your device.',
    ),
    (
      title: 'Authentication',
      body: 'Rhythm supports sign-in via Google, Apple, and email magic '
          'link through Supabase Auth. Rhythm does not store your '
          'password. The only profile information retained is your '
          'email address and authentication provider identifier.',
    ),
    (
      title: 'Local Preferences',
      body: 'App preferences such as alert settings (notifications and '
          'sound toggles) are stored locally on your device using '
          'SharedPreferences and are never transmitted to a server.',
    ),
    (
      title: 'Notifications',
      body: 'If you enable notifications, Rhythm schedules local '
          'notifications on your device to alert you when focus or '
          'break sessions complete. No notification data is sent to '
          'external services.',
    ),
    (
      title: 'Account Deletion',
      body: 'You can delete your account at any time from Settings. '
          'Deleting your account permanently removes all associated '
          'data (tasks, projects, sessions) from the cloud database.',
    ),
    (
      title: 'Changes to This Policy',
      body: 'If this policy changes, the updated version will be published '
          'at this same URL. Continued use of Rhythm after changes '
          'constitutes acceptance of the updated policy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: PageEntryAnimation(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
                ).copyWith(
                  top: isDesktop ? AppSpacing.huge : AppSpacing.xl * 2,
                  bottom: AppSpacing.xxl,
                ),
                children: [
                  StandalonePageHeader(
                    title: 'Privacy Policy',
                    iconData: Icons.shield_outlined,
                    iconBgColor: AppColors.blue50,
                    iconFgColor: AppColors.blue600,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge * 1.3 : AppSpacing.xxl,
                  ),
                  if (isDesktop)
                    _buildDesktopSections()
                  else
                    _buildMobileSections(),
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
      ),
    );
  }

  Widget _buildMobileSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _sections.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.huge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.title,
                style: AppTypography.bodyBase.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.body,
                style: AppTypography.bodyBase.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  height: 1.7,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopSections() {
    return Column(
      children: [
        for (var i = 0; i < _sections.length; i++) ...[
          if (i > 0)
            const Divider(height: 1, color: AppColors.surfaceBorderLight),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    _sections[i].title,
                    style: AppTypography.bodyBase.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxxl),
                Expanded(
                  flex: 8,
                  child: Text(
                    _sections[i].body,
                    style: AppTypography.bodyBase.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

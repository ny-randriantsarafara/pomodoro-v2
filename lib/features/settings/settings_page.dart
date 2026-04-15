import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/auth_repository.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(alertSettingsControllerProvider);
    final settings = controller.value;
    final authRepo = ref.watch(authRepositoryProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Settings', style: AppTypography.headingXl),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
                _SectionHeader(title: 'ALERTS'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Notifications',
                        style: AppTypography.bodyBase.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Get notified when sessions complete',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: settings.notificationsEnabled,
                      onChanged: (v) => controller.setNotificationsEnabled(v),
                      activeTrackColor: AppColors.neutral900,
                    ),
                    const Divider(height: 1, color: AppColors.surfaceBorderLight),
                    SwitchListTile(
                      title: Text(
                        'Sound',
                        style: AppTypography.bodyBase.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Play a sound when sessions complete',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: settings.soundEnabled,
                      onChanged: (v) => controller.setSoundEnabled(v),
                      activeTrackColor: AppColors.neutral900,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _SectionHeader(title: 'ABOUT'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  children: [
                    ListTile(
                      title: Text(
                        'Privacy Policy',
                        style: AppTypography.bodyBase.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.neutral400,
                      ),
                      onTap: () => context.go('/privacy'),
                    ),
                  ],
                ),
                if (isAuthenticated) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionHeader(title: 'ACCOUNT'),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsCard(
                    children: [
                      ListTile(
                        title: Text(
                          'Sign Out',
                          style: AppTypography.bodyBase.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onTap: () => authRepo.signOut(),
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.surfaceBorderLight,
                      ),
                      ListTile(
                        title: Text(
                          'Delete Account',
                          style: AppTypography.bodyBase.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                        onTap: () =>
                            _showDeleteConfirmation(context, authRepo),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showDeleteConfirmation(
  BuildContext context,
  AuthRepository authRepo,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'This will permanently delete your account and all data. '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            authRepo.deleteAccount();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructive,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        title,
        style: AppTypography.labelUppercaseXs.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

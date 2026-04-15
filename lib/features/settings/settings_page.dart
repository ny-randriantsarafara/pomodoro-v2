import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/auth_repository.dart';
import '../../shared/widgets/page_entry_animation.dart';
import '../../shared/widgets/settings_section_card.dart';
import '../../shared/widgets/settings_section_title.dart';
import '../../shared/widgets/standalone_page_header.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _breakpoint = 768.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(alertSettingsControllerProvider);
    final settings = controller.value;
    final authRepo = ref.watch(authRepositoryProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
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
                    title: 'Settings',
                    iconData: Icons.settings_outlined,
                    iconBgColor: AppColors.neutral100,
                    iconFgColor: AppColors.neutral700,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge : AppSpacing.xl * 2,
                  ),
                  const SettingsSectionTitle(title: 'ALERTS'),
                  SizedBox(height: isDesktop ? AppSpacing.lg : AppSpacing.md),
                  SettingsSectionCard(
                    isDesktop: isDesktop,
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        iconBgColor: AppColors.blue50,
                        iconFgColor: AppColors.blue600,
                        title: 'Notifications',
                        subtitle: 'Get notified when sessions complete',
                        value: settings.notificationsEnabled,
                        onChanged: controller.setNotificationsEnabled,
                        isDesktop: isDesktop,
                      ),
                      _ToggleRow(
                        icon: Icons.volume_up_outlined,
                        iconBgColor: AppColors.emeraldBg,
                        iconFgColor: AppColors.emeraldFg,
                        title: 'Sound',
                        subtitle: 'Play a sound when sessions complete',
                        value: settings.soundEnabled,
                        onChanged: controller.setSoundEnabled,
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge : AppSpacing.xl * 2,
                  ),
                  const SettingsSectionTitle(title: 'ABOUT'),
                  SizedBox(height: isDesktop ? AppSpacing.lg : AppSpacing.md),
                  SettingsSectionCard(
                    isDesktop: isDesktop,
                    children: [
                      _NavigationRow(
                        icon: Icons.shield_outlined,
                        iconBgColor: AppColors.neutral100,
                        iconFgColor: AppColors.neutral600,
                        title: 'Privacy Policy',
                        onTap: () => context.push('/privacy'),
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                  if (isAuthenticated) ...[
                    SizedBox(
                      height: isDesktop ? AppSpacing.huge : AppSpacing.xl * 2,
                    ),
                    const SettingsSectionTitle(title: 'ACCOUNT'),
                    SizedBox(height: isDesktop ? AppSpacing.lg : AppSpacing.md),
                    SettingsSectionCard(
                      children: [
                        _ActionRow(
                          title: 'Sign Out',
                          onTap: () => authRepo.signOut(),
                          isDesktop: isDesktop,
                        ),
                        _ActionRow(
                          title: 'Delete Account',
                          textColor: AppColors.destructive,
                          onTap: () =>
                              _showDeleteConfirmation(context, authRepo),
                          isDesktop: isDesktop,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconFgColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDesktop;

  const _ToggleRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconFgColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Icon(icon, color: iconFgColor, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyBase.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.neutral900,
          ),
        ],
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconFgColor;
  final String title;
  final VoidCallback onTap;
  final bool isDesktop;

  const _NavigationRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconFgColor,
    required this.title,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.neutral50,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Icon(icon, color: iconFgColor, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyBase.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final Color? textColor;
  final VoidCallback onTap;
  final bool isDesktop;

  const _ActionRow({
    required this.title,
    this.textColor,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.neutral50,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: AppTypography.bodyBase.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

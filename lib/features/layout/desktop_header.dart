import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_icon.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DesktopHeader extends ConsumerWidget {
  const DesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isFocus = location == '/';
    final isRhythm = location == '/history';
    final authRepo = ref.watch(authRepositoryProvider);
    final isAuthenticated = authRepo.currentUser != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: Row(
                  children: [
                    const Row(
                      children: [
                        AppLogoIcon(size: 32),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Rhythm',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadii.borderXl,
                        border: Border.all(color: AppColors.neutral200),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Row(
                        children: [
                          _NavTab(
                            icon: LucideIcons.listTodo,
                            label: 'Focus',
                            isActive: isFocus,
                            onTap: () => context.go('/'),
                          ),
                          _NavTab(
                            icon: LucideIcons.barChart3,
                            label: 'Rhythm',
                            isActive: isRhythm,
                            onTap: () => context.go('/history'),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (isAuthenticated) {
                            authRepo.signOut();
                          } else {
                            context.go('/auth');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadii.borderLg,
                          ),
                          child: Text(
                            isAuthenticated ? 'Sign Out' : 'Sign In',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: AppRadii.borderLg,
            boxShadow: isActive ? AppShadows.sm : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.neutral900 : AppColors.neutral500,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isActive ? AppColors.neutral900 : AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

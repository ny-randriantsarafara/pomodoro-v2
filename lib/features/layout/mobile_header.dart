import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_icon.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class MobileHeader extends ConsumerWidget {
  const MobileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).padding.top;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x80E5E5E5),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: topInset + AppSpacing.lg,
              bottom: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    AppLogoIcon(size: 28),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Rhythm',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
                if (isAuthenticated)
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: Text(
                        'Account',
                        style: AppTypography.bodyXs.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => context.go('/auth'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTypography.bodyXs.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

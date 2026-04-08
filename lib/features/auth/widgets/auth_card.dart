import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'auth_input_field.dart';
import 'shimmer_button.dart';

class AuthCard extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final TextEditingController emailController;
  final FocusNode emailFocus;
  final VoidCallback onMagicLink;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const AuthCard({
    super.key,
    required this.isLoading,
    this.message,
    required this.emailController,
    required this.emailFocus,
    required this.onMagicLink,
    required this.onGoogle,
    required this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogoIcon(size: 48)),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Welcome to Rhythm',
            textAlign: TextAlign.center,
            style: AppTypography.heading2xl.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to save your focus sessions',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AuthInputField(
            controller: emailController,
            focusNode: emailFocus,
            hintText: 'Email',
            icon: LucideIcons.mail,
          ),
          const SizedBox(height: AppSpacing.md),
          ShimmerButton(
            isLoading: isLoading,
            label: 'Send magic link',
            onPressed: onMagicLink,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.neutral300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'or',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.neutral300)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _OAuthButton(
            label: 'Continue with Google',
            icon: LucideIcons.chrome,
            onTap: onGoogle,
          ),
          const SizedBox(height: AppSpacing.md),
          _OAuthButton(
            label: 'Continue with Apple',
            icon: LucideIcons.apple,
            onTap: onApple,
          ),
        ],
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.neutral700),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

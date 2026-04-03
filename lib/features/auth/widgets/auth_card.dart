import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'auth_input_field.dart';
import 'shimmer_button.dart';

class AuthCard extends StatelessWidget {
  final bool isSignUp;
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode nameFocus;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  const AuthCard({
    super.key,
    required this.isSignUp,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.nameFocus,
    required this.onSubmit,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
            boxShadow: AppShadows.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogoIcon(size: 48),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offset,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  isSignUp ? 'Join Rhythm' : 'Welcome back',
                  key: ValueKey(isSignUp ? 'signup-title' : 'signin-title'),
                  style: AppTypography.heading2xl.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                child: Text(
                  isSignUp
                      ? 'Create an account to save your focus sessions'
                      : 'Sign in to continue your focus journey',
                  key: ValueKey(isSignUp ? 'signup-desc' : 'signin-desc'),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: AppMotion.smoothCurve,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isSignUp ? 1.0 : 0.0,
                  child: isSignUp
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AuthInputField(
                            controller: nameController,
                            focusNode: nameFocus,
                            hintText: 'Full name',
                            icon: LucideIcons.user,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              AuthInputField(
                controller: emailController,
                focusNode: emailFocus,
                hintText: 'Email',
                icon: LucideIcons.mail,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthInputField(
                controller: passwordController,
                focusNode: passwordFocus,
                hintText: 'Password',
                icon: LucideIcons.lock,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ShimmerButton(
                isLoading: isLoading,
                label: isSignUp ? 'Create Account' : 'Continue',
                onPressed: onSubmit,
              ),
              const SizedBox(height: AppSpacing.xl),
              _ModeSwitch(
                isSignUp: isSignUp,
                onToggle: onToggleMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatefulWidget {
  final bool isSignUp;
  final VoidCallback onToggle;

  const _ModeSwitch({required this.isSignUp, required this.onToggle});

  @override
  State<_ModeSwitch> createState() => _ModeSwitchState();
}

class _ModeSwitchState extends State<_ModeSwitch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final prompt = widget.isSignUp ? 'Already have an account? ' : "Don't have an account? ";
    final action = widget.isSignUp ? 'Sign in' : 'Sign up';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: RichText(
          text: TextSpan(
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            children: [
              TextSpan(text: prompt),
              WidgetSpan(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      tween: Tween<double>(end: _hovered ? 1 : 0),
                      builder: (context, value, child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.diagonal3Values(value, 1.0, 1.0),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

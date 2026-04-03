import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_motion.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogoIcon(size: 48)),
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
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
          Center(
            child: _ModeSwitch(isSignUp: isSignUp, onToggle: onToggleMode),
          ),
        ],
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

class _ModeSwitchState extends State<_ModeSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _underlineController;
  late final Animation<double> _underlineCurve;

  @override
  void initState() {
    super.initState();
    _underlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _underlineCurve = CurvedAnimation(
      parent: _underlineController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant _ModeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSignUp != widget.isSignUp) {
      _underlineController.value = 0;
    }
  }

  @override
  void dispose() {
    _underlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.isSignUp
        ? 'Already have an account?'
        : "Don't have an account?";
    final action = widget.isSignUp ? 'Sign in' : 'Sign up';

    return MouseRegion(
      onEnter: (_) => _underlineController.forward(),
      onExit: (_) => _underlineController.reverse(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      action,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AnimatedBuilder(
                      animation: _underlineCurve,
                      builder: (context, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _underlineCurve.value,
                            child: child,
                          ),
                        );
                      },
                      child: const ColoredBox(
                        color: AppColors.neutral900,
                        child: SizedBox(height: 2, width: double.infinity),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'widgets/auth_background_blobs.dart';
import 'widgets/auth_card.dart';
import 'widgets/floating_sparkles.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool isSignUp = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final nameFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      if (isSignUp) {
        await authRepo.signUp(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await authRepo.signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      }
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.indigoBg.withValues(alpha: 0.38),
                    AppColors.purpleBg.withValues(alpha: 0.28),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.34, 0.65, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: AuthBackgroundBlobs()),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.huge,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: _AuthGlassPanel(
                              child: AuthCard(
                                isSignUp: isSignUp,
                                isLoading: isLoading,
                                emailController: emailController,
                                passwordController: passwordController,
                                nameController: nameController,
                                emailFocus: emailFocus,
                                passwordFocus: passwordFocus,
                                nameFocus: nameFocus,
                                onSubmit: _handleSubmit,
                                onToggleMode: () =>
                                    setState(() => isSignUp = !isSignUp),
                              ),
                            ),
                          ),
                          if (isLargeScreen) ...[
                            const SizedBox(height: AppSpacing.xxl),
                            FloatingSparkles(visible: isSignUp),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.5),
                        borderRadius: AppRadii.borderLg,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted panel: semi-transparent fill and border work on mobile, web, and
/// desktop without relying on [BackdropFilter], which is inconsistent there.
class _AuthGlassPanel extends StatelessWidget {
  final Widget child;

  const _AuthGlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.42),
        borderRadius: AppRadii.borderXxxl,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.62),
          width: 1,
        ),
        boxShadow: [
          ...AppShadows.lg,
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.45),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: child,
      ),
    );
  }
}

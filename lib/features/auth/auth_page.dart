import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/logging/app_logger.dart';
import '../../store/providers.dart';
import 'auth_user_message.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'widgets/auth_background_blobs.dart';
import 'widgets/auth_card.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool isLoading = false;
  String? message;
  final emailController = TextEditingController();
  final emailFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  Future<void> _handleMagicLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      isLoading = true;
      message = null;
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithMagicLink(email);
      if (mounted) {
        setState(() {
          isLoading = false;
          message = 'Check your email for the login link!';
        });
      }
    } catch (e, st) {
      AppLogger.error(
        domain: 'auth',
        event: 'magic_link_request_failed',
        context: {
          'action': 'signInWithMagicLink',
          'email': email,
        },
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() {
          isLoading = false;
          message = userVisibleAuthErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handleGoogle() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
    } catch (e, st) {
      AppLogger.error(
        domain: 'auth',
        event: 'oauth_google_failed',
        context: {'action': 'signInWithGoogle'},
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _handleApple() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithApple();
    } catch (e, st) {
      AppLogger.error(
        domain: 'auth',
        event: 'oauth_apple_failed',
        context: {'action': 'signInWithApple'},
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: _AuthGlassPanel(
                              child: AuthCard(
                                isLoading: isLoading,
                                message: message,
                                emailController: emailController,
                                emailFocus: emailFocus,
                                onMagicLink: _handleMagicLink,
                                onGoogle: _handleGoogle,
                                onApple: _handleApple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

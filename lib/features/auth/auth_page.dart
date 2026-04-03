import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../store/providers.dart';
import '../../theme/app_colors.dart';
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

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: AuthBackgroundBlobs()),
        Positioned.fill(
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.7),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                    boxShadow: AppShadows.xl,
                  ),
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
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
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
            ),
          ),
        ),
      ],
    );
  }
}

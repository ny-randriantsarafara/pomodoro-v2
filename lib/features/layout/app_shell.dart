import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'desktop_header.dart';
import 'mobile_header.dart';
import 'mobile_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _breakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (isDesktop) const DesktopHeader() else const MobileHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    right: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    top: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    bottom: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(),
    );
  }
}

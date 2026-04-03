import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _focused ? AppColors.white : AppColors.white.withValues(alpha: 0.7),
        borderRadius: AppRadii.borderXl,
        border: Border.all(
          color: _focused ? AppColors.neutral900 : AppColors.neutral200,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.neutral900.withValues(alpha: 0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        style: AppTypography.bodyBase.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: _focused ? AppColors.neutral900 : AppColors.neutral400,
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _focused ? AppColors.neutral900 : AppColors.neutral400,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyBase.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PresetOption {
  final int minutes;
  final String label;
  final String description;

  const PresetOption({required this.minutes, required this.label, required this.description});
}

const presetOptions = [
  PresetOption(minutes: 25, label: 'Quick focus', description: '25 / 5'),
  PresetOption(minutes: 50, label: 'Deep work', description: '50 / 10'),
  PresetOption(minutes: 90, label: 'Flow block', description: '90 / 20'),
];

class PresetPicker extends StatelessWidget {
  final int lastUsedPreset;
  final void Function(int minutes) onSelect;

  const PresetPicker({super.key, required this.lastUsedPreset, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderXl,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8))],
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text('CHOOSE MODE', style: AppTypography.labelUppercaseXs.copyWith(color: AppColors.neutral400)),
          ),
          const Divider(height: 1, color: AppColors.neutral50),
          const SizedBox(height: 4),
          ...presetOptions.map((preset) {
            final isSelected = preset.minutes == lastUsedPreset;
            return GestureDetector(
              onTap: () => onSelect(preset.minutes),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neutral900 : Colors.transparent,
                  borderRadius: AppRadii.borderLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(preset.label, style: AppTypography.bodyBase.copyWith(fontWeight: FontWeight.w600, color: isSelected ? AppColors.white : AppColors.neutral900)),
                        const SizedBox(height: 2),
                        Text('${preset.minutes} min focus', style: AppTypography.bodyXs.copyWith(color: isSelected ? AppColors.neutral300 : AppColors.neutral500)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neutral800 : AppColors.white,
                        borderRadius: AppRadii.borderSm,
                        border: Border.all(color: isSelected ? AppColors.neutral700 : AppColors.neutral200),
                      ),
                      child: Text(preset.description, style: AppTypography.bodyXs.copyWith(color: isSelected ? AppColors.neutral300 : AppColors.neutral500)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/page_entry_animation.dart';
import '../../shared/widgets/standalone_page_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const _breakpoint = 768.0;
  static const _envEmail = String.fromEnvironment('SUPPORT_EMAIL');
  static const _supportEmail =
      _envEmail == '' ? 'support@rhythm-app.com' : _envEmail;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: PageEntryAnimation(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
                ).copyWith(
                  top: isDesktop ? AppSpacing.huge : AppSpacing.xl * 2,
                  bottom: AppSpacing.xxl,
                ),
                children: [
                  StandalonePageHeader(
                    title: 'Support',
                    subtitle: 'Rhythm Task-centered Pomodoro app',
                    iconData: Icons.headset_mic_outlined,
                    iconBgColor: AppColors.rose50,
                    iconFgColor: AppColors.rose600,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge : AppSpacing.xxxl,
                  ),
                  _ContactSection(isDesktop: isDesktop),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge : AppSpacing.xxxl,
                  ),
                  _FaqSection(isDesktop: isDesktop),
                  SizedBox(
                    height: isDesktop ? AppSpacing.huge : AppSpacing.xxxl,
                  ),
                  _PrivacyLinkSection(isDesktop: isDesktop),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final bool isDesktop;

  const _ContactSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: isDesktop
              ? AppTypography.headingXl
              : AppTypography.headingLg.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: isDesktop ? AppSpacing.xxl : AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                isDesktop ? AppRadii.borderXxl : AppRadii.borderXl,
            border: Border.all(
              color: AppColors.surfaceBorder.withValues(alpha: 0.8),
            ),
            boxShadow: AppShadows.sm,
          ),
          padding: EdgeInsets.all(
            isDesktop ? AppSpacing.xxxl : AppSpacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isDesktop ? 48 : 40,
                height: isDesktop ? 48 : 40,
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Icon(
                  Icons.mail_outlined,
                  color: AppColors.blue600,
                  size: isDesktop ? 24 : 20,
                ),
              ),
              SizedBox(width: isDesktop ? AppSpacing.xl : AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If you need help, have a question, or want to report a bug, please email us directly at:',
                      style: AppTypography.bodyBase.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _EmailLink(
                      email: SupportPage._supportEmail,
                      isDesktop: isDesktop,
                    ),
                    SizedBox(
                      height: isDesktop ? AppSpacing.xl : AppSpacing.lg,
                    ),
                    Text(
                      'We aim to respond to all inquiries within 24-48 hours.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailLink extends StatefulWidget {
  final String email;
  final bool isDesktop;

  const _EmailLink({required this.email, required this.isDesktop});

  @override
  State<_EmailLink> createState() => _EmailLinkState();
}

class _EmailLinkState extends State<_EmailLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SelectableText(
        widget.email,
        style: (widget.isDesktop
                ? AppTypography.headingXl
                : AppTypography.headingLg)
            .copyWith(
          color: _hovering ? AppColors.blue600 : AppColors.textPrimary,
          decoration:
              _hovering ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.blue600,
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final bool isDesktop;

  const _FaqSection({required this.isDesktop});

  static const _faqs = [
    (
      question: 'How does Rhythm sync my data?',
      answer:
          'When you are signed in, Rhythm automatically syncs your tasks, projects, and sessions across devices. If you are using Rhythm without an account, your data remains only on your device.',
    ),
    (
      question: 'How do presets work?',
      answer:
          'You can configure default focus and break times for your tasks. The timer will automatically apply these presets when you start a session.',
    ),
    (
      question: 'Does Rhythm support offline mode?',
      answer:
          'Yes, Rhythm works seamlessly offline and will sync any changes the next time you connect to the internet.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: isDesktop
              ? AppTypography.headingXl
              : AppTypography.headingLg.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: isDesktop ? AppSpacing.xxl : AppSpacing.lg),
        ..._faqs.map(
          (faq) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _FaqCard(
              question: faq.question,
              answer: faq.answer,
              isDesktop: isDesktop,
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isDesktop;

  const _FaqCard({
    required this.question,
    required this.answer,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderXl,
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.8),
        ),
        boxShadow: AppShadows.sm,
      ),
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xxl : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.help_outline,
                size: isDesktop ? 20 : 16,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: isDesktop
                      ? AppTypography.headingLg
                      : AppTypography.bodyBase.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? AppSpacing.md : AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(
              left: isDesktop ? 30.0 : AppSpacing.xxl,
            ),
            child: Text(
              answer,
              style: AppTypography.bodyBase.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyLinkSection extends StatelessWidget {
  final bool isDesktop;

  const _PrivacyLinkSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop ? AppRadii.borderXxl : AppRadii.borderXl;

    return Material(
      color: AppColors.neutral50,
      borderRadius: radius,
      child: InkWell(
        onTap: () => context.push('/privacy'),
        borderRadius: radius,
        hoverColor: AppColors.neutral100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: AppColors.surfaceBorder.withValues(alpha: 0.8),
            ),
          ),
          padding: EdgeInsets.all(
            isDesktop ? AppSpacing.xxl : AppSpacing.xl,
          ),
          child: isDesktop ? _buildDesktop() : _buildMobile(),
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconCircle(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Privacy Policy',
          style: AppTypography.bodyBase.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'View our privacy policy to see how we handle your data.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        _iconCircle(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: AppTypography.headingLg),
              const SizedBox(height: 4),
              Text(
                'View our privacy policy to see how we handle your data.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: AppColors.neutral400,
          size: 20,
        ),
      ],
    );
  }

  Widget _iconCircle() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: const Icon(
        Icons.shield_outlined,
        color: AppColors.neutral700,
        size: 20,
      ),
    );
  }
}

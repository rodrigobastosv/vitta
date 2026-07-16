import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_presentation_event.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTPage<OnboardingCubit, OnboardingState, OnboardingPresentationEvent>(
      builder: (context, cubit, state) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VTSpacing.l),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.eco_outlined, size: 32, color: colorScheme.onPrimaryContainer),
                ),
                const VTGap.l(),
                Text(l10n.onboardingWelcomeTitle, style: VTTextStyles.display(context)),
                const VTGap.s(),
                Text(l10n.onboardingWelcomeMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
                const VTGap.xl(),
                _OnboardingFeatureRow(icon: Icons.restaurant_outlined, title: l10n.dietFeatureTitle, subtitle: l10n.dietFeatureSubtitle),
                const VTGap.m(),
                _OnboardingFeatureRow(icon: Icons.water_drop_outlined, title: l10n.waterFeatureTitle, subtitle: l10n.waterFeatureSubtitle),
                const VTGap.m(),
                _OnboardingFeatureRow(icon: Icons.bedtime_outlined, title: l10n.sleepFeatureTitle, subtitle: l10n.sleepFeatureSubtitle),
                const VTGap.m(),
                _OnboardingFeatureRow(
                  icon: Icons.fitness_center_outlined,
                  title: l10n.workoutFeatureTitle,
                  subtitle: l10n.workoutFeatureSubtitle,
                ),
                const VTGap.xl(),
                Text(l10n.onboardingAccountBenefitMessage, style: VTTextStyles.caption(context)),
                const VTGap.m(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final linked = await context.pushRoute<bool>(.signUp) ?? false;
                      if (linked && context.mounted) {
                        await cubit.completeOnboarding();
                        if (context.mounted) {
                          context.goRoute(.home);
                        }
                      }
                    },
                    child: Text(l10n.onboardingCreateAccountAction),
                  ),
                ),
                const VTGap.s(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      cubit.completeOnboarding();
                      context.goRoute(.home);
                    },
                    child: Text(l10n.onboardingContinueWithoutAccountAction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingFeatureRow extends StatelessWidget {
  const _OnboardingFeatureRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(VTSpacing.s),
          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: VTRadius.borderRadiusM),
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(title, style: VTTextStyles.bodyStrong(context)),
              Text(subtitle, style: VTTextStyles.caption(context)),
            ],
          ),
        ),
      ],
    );
  }
}

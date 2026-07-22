import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_presentation_event.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_account_step.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_body_step.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_features_step.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_goals_step.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_step_indicator.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_welcome_step.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _bodyStep = 2;
  static const int _goalsStep = 3;

  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int step) => _controller.animateToPage(step, duration: VTMotion.transition, curve: VTMotion.curve);

  Future<void> _finish(BuildContext context, OnboardingCubit cubit) async {
    await cubit.completeOnboarding();
    if (context.mounted) {
      context.goRoute(.home);
    }
  }

  void _acceptBodyThenNext(OnboardingCubit cubit) {
    cubit.acceptBody();
    _goTo(_bodyStep + 1);
  }

  void _acceptGoalsThenNext(OnboardingCubit cubit) {
    cubit.acceptGoals();
    _goTo(_goalsStep + 1);
  }

  // Skipping the body skips the goals too: the suggestion is derived from the
  // weight and height, so a goals step with no body behind it has nothing to
  // suggest.
  void _skipToAccount() => _goTo(_goalsStep + 1);

  bool _isSkippableStep(int step) => step == _bodyStep || step == _goalsStep;

  void _next(OnboardingCubit cubit, int step) => switch (step) {
    _bodyStep => _acceptBodyThenNext(cubit),
    _goalsStep => _acceptGoalsThenNext(cubit),
    _ => _goTo(step + 1),
  };

  Future<void> _authenticateThenFinish(BuildContext context, OnboardingCubit cubit, AppRoute route) async {
    final authenticated = await context.pushRoute<bool>(route) ?? false;
    if (authenticated && context.mounted) {
      await _finish(context, cubit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<OnboardingCubit, OnboardingState, OnboardingPresentationEvent>(
      builder: (context, cubit, state) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: cubit.goToStep,
                  children: [
                    const OnboardingWelcomeStep(),
                    const OnboardingFeaturesStep(),
                    OnboardingBodyStep(
                      unitSystem: cubit.unitSystem,
                      weightKg: state.weightKg,
                      heightCm: state.heightCm,
                      objective: state.objective,
                      onWeightChanged: cubit.weightChanged,
                      onHeightChanged: cubit.heightChanged,
                      onObjectiveChanged: cubit.objectiveChanged,
                    ),
                    OnboardingGoalsStep(
                      calorieGoal: state.effectiveCalorieGoal,
                      goals: state.goals,
                      objective: state.objective,
                      onChanged: cubit.calorieGoalChanged,
                    ),
                    const OnboardingAccountStep(),
                  ],
                ),
              ),
              const VTGap.m(),
              OnboardingStepIndicator(stepCount: OnboardingState.stepCount, step: state.step),
              const VTGap.l(),
              Padding(
                padding: const EdgeInsets.fromLTRB(VTSpacing.l, 0, VTSpacing.l, VTSpacing.m),
                child: state.isLastStep
                    ? Column(
                        children: [
                          VTPrimaryButton(label: l10n.onboardingCreateAccountAction, onPressed: () => _authenticateThenFinish(context, cubit, .signUp)),
                          const VTGap.m(),
                          TextButton(onPressed: () => _authenticateThenFinish(context, cubit, .signIn), child: Text(l10n.authHasAccountAction)),
                          TextButton(onPressed: () => _finish(context, cubit), child: Text(l10n.onboardingContinueWithoutAccountAction)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          VTPrimaryButton(label: l10n.onboardingNextAction, onPressed: () => _next(cubit, state.step)),
                          const VTGap.s(),
                          TextButton(
                            onPressed: _isSkippableStep(state.step) ? _skipToAccount : () => _finish(context, cubit),
                            child: Text(_isSkippableStep(state.step) ? l10n.onboardingGoalsSkipAction : l10n.onboardingContinueWithoutAccountAction),
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

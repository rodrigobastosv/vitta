import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({required this.stepCount, required this.step, super.key});

  final int stepCount;
  final int step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: .center,
      children: [
        for (var index = 0; index < stepCount; index++)
          AnimatedContainer(
            duration: VTMotion.transition,
            curve: VTMotion.curve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == step ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: index == step ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: VTRadius.borderRadiusFull,
            ),
          ),
      ],
    );
  }
}

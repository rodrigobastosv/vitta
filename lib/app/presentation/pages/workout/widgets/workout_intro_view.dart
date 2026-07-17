import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutIntroView extends StatelessWidget {
  const WorkoutIntroView({required this.onCreateRoutine, required this.onSkip, super.key});

  final VoidCallback onCreateRoutine;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(VTSpacing.l),
          child: VTAppearEffect(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.fitness_center, size: 32, color: colorScheme.onPrimaryContainer),
                ),
                const VTGap.l(),
                Text(l10n.workoutIntroTitle, style: VTTextStyles.display(context)),
                const VTGap.s(),
                Text(l10n.workoutIntroSubtitle, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
                const VTGap.xl(),
                _point(context, icon: Icons.checklist_rounded, title: l10n.workoutIntroLogTitle, message: l10n.workoutIntroLogMessage),
                const VTGap.l(),
                _point(
                  context,
                  icon: Icons.trending_up_rounded,
                  title: l10n.workoutIntroProgressTitle,
                  message: l10n.workoutIntroProgressMessage,
                ),
                const VTGap.xl(),
                VTCard(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded, color: colorScheme.primary, size: 20),
                          const VTGap.s(),
                          Expanded(child: Text(l10n.workoutIntroRoutineTitle, style: VTTextStyles.title(context))),
                        ],
                      ),
                      const VTGap.s(),
                      Text(
                        l10n.workoutIntroRoutineMessage,
                        style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const VTGap.xl(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreateRoutine,
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(l10n.workoutIntroCreateRoutineAction),
                  ),
                ),
                const VTGap.s(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(onPressed: onSkip, child: Text(l10n.workoutIntroSkipAction)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _point(BuildContext context, {required IconData icon, required String title, required String message}) {
    final colorScheme = context.colorScheme;
    return Row(
      crossAxisAlignment: .start,
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
              const VTGap.xs(),
              Text(message, style: VTTextStyles.caption(context)),
            ],
          ),
        ),
      ],
    );
  }
}

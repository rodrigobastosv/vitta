import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/workout_summary_exercise_tile.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/workout_summary_hero.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';

/// The end-of-workout payoff screen. It **has no cubit**: the workout page hands
/// the finished day over whole through [WorkoutSummaryExtra], so there is nothing
/// left to fetch (`DietDayPage`'s reasoning), and it is read-only by nature -
/// editing a set happens back on the day view.
class WorkoutSummaryPage extends StatelessWidget {
  const WorkoutSummaryPage({required this.extra, super.key});

  final WorkoutSummaryExtra extra;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = extra.state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.xxl),
        children: [
          WorkoutSummaryHero(date: state.date, celebrate: extra.celebrate),
          const VTGap.l(),
          VTAppearEffect(
            index: 1,
            child: WorkoutSummaryCard(state: state, unitSystem: extra.unitSystem),
          ),
          const VTGap.l(),
          if (state.exercises.isNotEmpty) ...[
            Text(l10n.workoutSummaryExercisesTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            for (final (index, workoutExercise) in state.exercises.indexed) ...[
              VTAppearEffect(
                index: index + 2,
                child: WorkoutSummaryExerciseTile(workoutExercise: workoutExercise, unitSystem: extra.unitSystem),
              ),
              const VTGap.m(),
            ],
          ],
          const VTGap.s(),
          VTPrimaryButton(label: l10n.workoutSummaryDoneAction, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

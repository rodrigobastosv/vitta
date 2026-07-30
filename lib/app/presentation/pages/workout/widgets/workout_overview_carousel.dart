import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/presentation/general/workout_body_map_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

class WorkoutOverviewCarousel extends StatefulWidget {
  const WorkoutOverviewCarousel({required this.state, required this.unitSystem, required this.bodyFigure, super.key});

  final WorkoutState state;
  final UnitSystem unitSystem;
  final VTBodyFigure bodyFigure;

  @override
  State<WorkoutOverviewCarousel> createState() => _WorkoutOverviewCarouselState();
}

// A PageView was the first cut and it needs a bounded height, which this content
// cannot supply: WorkoutSummaryCard grows from two metric rows to five once there
// is cardio and distance, and its region badges wrap. Any constant tall enough for
// one session overflows another. A Row inside a horizontal scroll view takes the
// unbounded height the vertical list already gives it, so the strip is as tall as
// its tallest page and can never overflow; PageScrollPhysics keeps the snap.
//
// IntrinsicHeight is what makes the two cards the *same* height. Without it the
// Row sizes to the tallest child while each card keeps its own, so swiping
// between a short page and a tall one visibly resizes the card under the finger.
// CrossAxisAlignment.stretch alone cannot do it here - it forces the incoming
// cross-axis constraint onto its children, which in a vertical list is unbounded.
class _WorkoutOverviewCarouselState extends State<WorkoutOverviewCarousel> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final pages = [
      WorkoutSummaryCard(state: widget.state, unitSystem: widget.unitSystem),
      WorkoutBodyMapCard(
        muscleWork: widget.state.completedMuscleWork,
        hint: widget.state.isFinished ? l10n.workoutBodyMapHint : l10n.workoutBodyMapProgressHint,
        figure: widget.bodyFigure,
        isCompact: true,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: .horizontal,
            physics: const PageScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: .stretch,
                children: [
                  for (final page in pages) SizedBox(width: constraints.maxWidth, child: page),
                ],
              ),
            ),
          ),
          const VTGap.s(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final page = _controller.hasClients ? (_controller.offset / constraints.maxWidth).round() : 0;
              return Row(
                mainAxisAlignment: .center,
                children: [
                  for (final (index, _) in pages.indexed) ...[
                    if (index > 0) const VTGap.xs(),
                    AnimatedContainer(
                      duration: VTMotion.transition,
                      curve: VTMotion.curve,
                      width: index == page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == page ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                        borderRadius: VTRadius.borderRadiusFull,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

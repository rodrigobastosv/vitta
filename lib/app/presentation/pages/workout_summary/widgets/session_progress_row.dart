import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/session_progress.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SessionProgressRow extends StatelessWidget {
  const SessionProgressRow({required this.progress, required this.unitSystem, super.key});

  final SessionProgress progress;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    // Up is the only direction that gets a colour. A session that went down is not
    // a failure to be scolded for - it can be a deload, a bad night's sleep or an
    // honest day - so it reads in the same neutral ink as "same as last time",
    // with the arrow carrying the direction. Redundant shape-plus-colour, never
    // colour alone, is also what keeps it legible for colour-blind readers.
    final isUp = progress.direction == .up;
    final accent = isUp ? VTColors.success : colorScheme.onSurfaceVariant;
    // The verdict sits under the name rather than beside it: an exercise name and
    // a phrase like "+100 kg of volume" cannot share one line at 320px, and in pt
    // they are longer still - competing for the same row means one of them
    // ellipsises away exactly when there is something to say.
    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(_icon, size: 18, color: accent),
        const VTGap.s(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(progress.exercise.exercise.nameFor(l10n.localeName), style: VTTextStyles.body(context), maxLines: 1, overflow: .ellipsis),
              Text(_label(l10n), style: VTTextStyles.caption(context).copyWith(color: accent, fontWeight: .w700)),
            ],
          ),
        ),
      ],
    );
  }

  IconData get _icon => switch (progress.direction) {
    .first => Icons.fiber_new_outlined,
    .up => Icons.arrow_upward,
    .down => Icons.arrow_downward,
    .flat => Icons.trending_flat,
  };

  String _label(AppLocalizations l10n) => switch (progress.direction) {
    .first => l10n.workoutSummaryProgressFirst,
    .flat => l10n.workoutSummaryProgressFlat,
    .up || .down => progress.exercise.isCardio ? _durationLabel(l10n) : _volumeLabel(l10n),
  };

  String _durationLabel(AppLocalizations l10n) {
    final minutes = (progress.durationDeltaSeconds.abs() / 60).round();
    return progress.direction == .up ? l10n.workoutSummaryProgressUpDuration(minutes) : l10n.workoutSummaryProgressDownDuration(minutes);
  }

  String _volumeLabel(AppLocalizations l10n) {
    final delta = unitSystem.kilogramsToDisplayLoad(progress.volumeDeltaKg.abs()).round().toString();
    final unit = unitSystem.loadUnitLabel;
    return progress.direction == .up
        ? l10n.workoutSummaryProgressUpVolume(delta, unit)
        : l10n.workoutSummaryProgressDownVolume(delta, unit);
  }
}

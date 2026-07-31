import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/rest_timer_settings/widgets/rest_duration_label.dart';

class RestLengthCard extends StatelessWidget {
  const RestLengthCard({required this.rest, required this.onChanged, super.key});

  static const double restStep = 15;

  final Duration rest;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.workoutRestSettingTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.xs(),
          Text(l10n.workoutRestSettingHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          const VTGap.m(),
          VTLabeledSlider(
            label: l10n.workoutRestTimerLabel,
            valueLabel: restDurationLabel(rest),
            value: rest.inSeconds.toDouble(),
            min: RestTimerState.minRest.inSeconds.toDouble(),
            max: RestTimerState.maxRest.inSeconds.toDouble(),
            step: restStep,
            decreaseTooltip: l10n.adjustDecreaseAction(l10n.workoutRestTimerLabel),
            increaseTooltip: l10n.adjustIncreaseAction(l10n.workoutRestTimerLabel),
            color: colorScheme.primary,
            onChanged: (seconds) => onChanged(Duration(seconds: seconds.round())),
          ),
        ],
      ),
    );
  }
}

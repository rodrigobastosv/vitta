import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';

Future<Duration?> showRestLengthSheet({required BuildContext context, required Duration current}) => showModalBottomSheet<Duration>(
  context: context,
  routeSettings: VTBottomSheet.restLength.settings,
  isScrollControlled: true,
  builder: (sheetContext) => RestLengthSheet(current: current),
);

class RestLengthSheet extends StatefulWidget {
  const RestLengthSheet({required this.current, super.key});

  final Duration current;

  @override
  State<RestLengthSheet> createState() => _RestLengthSheetState();
}

class _RestLengthSheetState extends State<RestLengthSheet> {
  late Duration _rest = widget.current;

  String _label(Duration rest) {
    final minutes = rest.inMinutes;
    final seconds = rest.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.l),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(l10n.workoutRestSettingTitle, style: VTTextStyles.title(context)),
            const VTGap.xs(),
            Text(l10n.workoutRestSettingHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
            const VTGap.l(),
            VTLabeledSlider(
              label: l10n.workoutRestTimerLabel,
              valueLabel: _label(_rest),
              value: _rest.inSeconds.toDouble(),
              min: RestTimerState.minRest.inSeconds.toDouble(),
              max: RestTimerState.maxRest.inSeconds.toDouble(),
              color: colorScheme.primary,
              onChanged: (seconds) => setState(() => _rest = Duration(seconds: (seconds / 15).round() * 15)),
            ),
            const VTGap.l(),
            FilledButton(onPressed: () => Navigator.of(context).pop(_rest), child: Text(l10n.saveAction)),
          ],
        ),
      ),
    );
  }
}

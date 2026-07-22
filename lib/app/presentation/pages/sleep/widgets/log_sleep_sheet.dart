import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_duration_hero.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_quality_selector.dart';
import 'package:vitta/app/presentation/pages/sleep/widgets/sleep_time_row.dart';

Future<void> showLogSleepSheet({required BuildContext context}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.logSleep.settings,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<SleepCubit>(), child: const _LogSleepSheet()),
);

class _LogSleepSheet extends StatefulWidget {
  const _LogSleepSheet();

  @override
  State<_LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends State<_LogSleepSheet> {
  late DateTime _wakeTime = DateTime.now();
  late DateTime _bedTime = _wakeTime.subtract(const Duration(hours: 8));
  int? _qualityRating;

  Duration get _duration => _wakeTime.difference(_bedTime);

  bool get _isValid => _duration > Duration.zero;

  Future<void> _pickDateTime({required DateTime initial, required ValueChanged<DateTime> onPicked}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (pickedTime == null) {
      return;
    }
    onPicked(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute));
  }

  Future<void> _submit() async {
    await context.read<SleepCubit>().logSleep(bedTime: _bedTime, wakeTime: _wakeTime, qualityRating: _qualityRating);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(left: VTSpacing.m, right: VTSpacing.m, top: VTSpacing.m, bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.sleepLogSheetTitle, style: VTTextStyles.title(context)),
          const VTGap.m(),
          SleepDurationHero(duration: _duration, isValid: _isValid),
          const VTGap.m(),
          SleepTimeRow(
            icon: Icons.bedtime_rounded,
            label: l10n.sleepBedTimeLabel,
            dateTime: _bedTime,
            onTap: () => _pickDateTime(initial: _bedTime, onPicked: (value) => setState(() => _bedTime = value)),
          ),
          const VTGap.s(),
          SleepTimeRow(
            icon: Icons.wb_sunny_rounded,
            label: l10n.sleepWakeTimeLabel,
            dateTime: _wakeTime,
            onTap: () => _pickDateTime(initial: _wakeTime, onPicked: (value) => setState(() => _wakeTime = value)),
          ),
          const VTGap.l(),
          SleepQualitySelector(rating: _qualityRating, onChanged: (rating) => setState(() => _qualityRating = rating)),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.sleepLogAction, onPressed: _isValid ? _submit : null),
        ],
      ),
    );
  }
}

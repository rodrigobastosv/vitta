import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/sleep/sleep_cubit.dart';

Future<void> showLogSleepSheet({required BuildContext context}) => showModalBottomSheet<void>(
  context: context,
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
  String? _errorMessage;

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
    final l10n = context.l10n;
    if (!_wakeTime.isAfter(_bedTime)) {
      setState(() => _errorMessage = l10n.sleepInvalidRange);
      return;
    }
    await context.read<SleepCubit>().logSleep(bedTime: _bedTime, wakeTime: _wakeTime, qualityRating: _qualityRating);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materialLocalizations = context.materialLocalizations;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.sleepLogSheetTitle, style: VTTextStyles.title(context)),
          const VTGap.m(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sleepBedTimeLabel),
            subtitle: Text(
              '${materialLocalizations.formatShortDate(_bedTime)} ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(_bedTime))}',
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _pickDateTime(initial: _bedTime, onPicked: (value) => setState(() => _bedTime = value)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sleepWakeTimeLabel),
            subtitle: Text(
              '${materialLocalizations.formatShortDate(_wakeTime)} ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(_wakeTime))}',
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _pickDateTime(initial: _wakeTime, onPicked: (value) => setState(() => _wakeTime = value)),
          ),
          const VTGap.m(),
          Text(l10n.sleepQualityLabel, style: VTTextStyles.body(context)),
          const VTGap.xs(),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(index < (_qualityRating ?? 0) ? Icons.star : Icons.star_border, color: Theme.of(context).colorScheme.primary),
                onPressed: () => setState(() => _qualityRating = _qualityRating == index + 1 ? null : index + 1),
              ),
            ),
          ),
          if (_errorMessage case final errorMessage?) ...[
            const VTGap.s(),
            Text(errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.sleepLogAction, onPressed: _submit),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_labels.dart';

Future<void> showReminderFormSheet({required BuildContext context, required ReminderCubit cubit, required DateTime date, Reminder? reminder}) =>
    showModalBottomSheet<void>(
      context: context,
      routeSettings: VTBottomSheet.reminderForm.settings,
      isScrollControlled: true,
      builder: (sheetContext) => _ReminderFormSheet(cubit: cubit, date: date, reminder: reminder),
    );

class _ReminderFormSheet extends StatefulWidget {
  const _ReminderFormSheet({required this.cubit, required this.date, this.reminder});

  final ReminderCubit cubit;
  final DateTime date;
  final Reminder? reminder;

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  late final TextEditingController _titleController = TextEditingController(text: widget.reminder?.title ?? '');
  late final TextEditingController _notesController = TextEditingController(text: widget.reminder?.notes ?? '');
  late DateTime _dueDate = widget.reminder?.dueDate ?? widget.date;
  late bool _remindEnabled = widget.reminder?.remindAt != null;
  late TimeOfDay _remindTime = TimeOfDay.fromDateTime(widget.reminder?.remindAt ?? _defaultRemindTime());
  late ReminderRecurrence _recurrence = widget.reminder?.recurrence ?? .none;
  bool _canSave = false;

  static DateTime _defaultRemindTime() => DateTime(2020, 1, 1, 9);

  @override
  void initState() {
    super.initState();
    _canSave = _titleController.text.trim().isNotEmpty;
    _titleController.addListener(() => setState(() => _canSave = _titleController.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _remindAt => _remindEnabled ? DateTime(_dueDate.year, _dueDate.month, _dueDate.day, _remindTime.hour, _remindTime.minute) : null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _remindTime);
    if (picked != null) {
      setState(() {
        _remindEnabled = true;
        _remindTime = picked;
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    if (widget.reminder case final reminder?) {
      widget.cubit.updateReminder(original: reminder, title: title, dueDate: _dueDate, notes: notes, remindAt: _remindAt, recurrence: _recurrence);
    } else {
      widget.cubit.createReminder(title: title, dueDate: _dueDate, notes: notes, remindAt: _remindAt, recurrence: _recurrence);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: VTSpacing.m, right: VTSpacing.m, top: VTSpacing.m, bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(widget.reminder == null ? l10n.reminderNewTitle : l10n.reminderEditTitle, style: VTTextStyles.title(context)),
          const VTGap.m(),
          TextField(
            controller: _titleController,
            autofocus: widget.reminder == null,
            textCapitalization: .sentences,
            decoration: InputDecoration(labelText: l10n.reminderTitleLabel, hintText: l10n.reminderTitleHint),
          ),
          const VTGap.s(),
          TextField(
            controller: _notesController,
            textCapitalization: .sentences,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.reminderNotesLabel),
          ),
          const VTGap.m(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.event_outlined, color: colorScheme.primary),
            title: Text(l10n.reminderDueDateLabel, style: VTTextStyles.body(context)),
            trailing: Text(context.materialLocalizations.formatMediumDate(_dueDate), style: VTTextStyles.bodyStrong(context)),
            onTap: _pickDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
            title: Text(l10n.reminderRemindLabel, style: VTTextStyles.body(context)),
            value: _remindEnabled,
            onChanged: (value) async {
              setState(() => _remindEnabled = value);
              if (value) {
                await _pickTime();
              }
            },
          ),
          if (_remindEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Align(
                alignment: .centerLeft,
                child: ActionChip(avatar: const Icon(Icons.schedule, size: 18), label: Text(_remindTime.format(context)), onPressed: _pickTime),
              ),
            ),
          const VTGap.m(),
          Row(
            children: [
              Icon(Icons.repeat_rounded, color: colorScheme.primary),
              const VTGap.m(),
              Text(l10n.reminderRepeatLabel, style: VTTextStyles.body(context)),
            ],
          ),
          const VTGap.s(),
          Wrap(
            spacing: VTSpacing.s,
            runSpacing: VTSpacing.xs,
            children: [
              for (final recurrence in ReminderRecurrence.values)
                ChoiceChip(
                  label: Text(recurrence.label(l10n)),
                  selected: _recurrence == recurrence,
                  showCheckmark: false,
                  onSelected: (_) {
                    VTHaptics.selection();
                    setState(() => _recurrence = recurrence);
                  },
                ),
            ],
          ),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.saveAction, onPressed: _canSave ? _submit : null),
        ],
      ),
    );
  }
}

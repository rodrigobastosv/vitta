import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_filter.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_presentation_event.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_state.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_date_selector.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_form_sheet.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_labels.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_tile.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ReminderCubit, ReminderState, ReminderPresentationEvent>(
      onPresentation: (context, event) {
        final cubit = context.read<ReminderCubit>();
        switch (event) {
          case ReminderShowLoading():
            context.showLoading();
          case ReminderHideLoading():
            context.hideLoading();
          case ReminderError(:final message):
            context.showErrorToast(message: message, onRetry: () => cubit.loadDate(cubit.state.date));
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.reminderTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: l10n.reminderHistoryTitle,
              onPressed: () => context.pushRoute(.reminderHistory),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showReminderFormSheet(context: context, cubit: cubit, date: state.date),
          icon: const Icon(Icons.add),
          label: Text(l10n.reminderAddAction),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
              child: ReminderDateSelector(
                date: state.date,
                onPreviousDay: cubit.previousDay,
                onNextDay: cubit.nextDay,
                onPickDate: cubit.goToDate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
              child: VTSegmentedTabs<ReminderFilter>(
                selected: state.filter,
                onSelected: cubit.changeFilter,
                tabs: [for (final filter in ReminderFilter.values) VTSegmentedTab(value: filter, label: filter.label(l10n))],
              ),
            ),
            Expanded(child: _ReminderList(state: state, cubit: cubit)),
          ],
        ),
      ),
    );
  }
}

class _ReminderList extends StatelessWidget {
  const _ReminderList({required this.state, required this.cubit});

  final ReminderState state;
  final ReminderCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reminders = state.visibleReminders;
    if (reminders.isEmpty) {
      return VTEmptyState(icon: Icons.check_circle_outline, title: l10n.reminderEmptyTitle, message: l10n.reminderEmptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.s, VTSpacing.m, VTSpacing.xxl),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => const VTGap.s(),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ReminderTile(
          reminder: reminder,
          onToggle: (completed) => cubit.setCompleted(reminder: reminder, completed: completed),
          onTap: () => showReminderFormSheet(context: context, cubit: cubit, date: state.date, reminder: reminder),
          onDelete: () => cubit.deleteReminder(reminder: reminder),
        );
      },
    );
  }
}

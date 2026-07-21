import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_state.dart';
import 'package:vitta/app/presentation/pages/reminder_history/widgets/reminder_day_section.dart';
import 'package:vitta/app/presentation/pages/reminder_history/widgets/reminder_history_calendar_card.dart';

class ReminderHistoryPage extends StatelessWidget {
  const ReminderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ReminderHistoryCubit, ReminderHistoryState, ReminderHistoryPresentationEvent>(
      onPresentation: (context, event) {
        final cubit = context.read<ReminderHistoryCubit>();
        switch (event) {
          case ReminderHistoryShowLoading():
            context.showLoading();
          case ReminderHistoryHideLoading():
            context.hideLoading();
          case ReminderHistoryError(:final message):
            context.showErrorToast(message: message, onRetry: () => cubit.loadMonth(cubit.state.month));
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.reminderHistoryTitle)),
        body: !state.hasData
            ? VTEmptyState(
                icon: Icons.event_available_outlined,
                title: l10n.reminderHistoryEmptyTitle,
                message: l10n.reminderHistoryEmptyMessage,
                actionLabel: l10n.reminderHistoryEmptyAction,
                onAction: () => Navigator.of(context).pop(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(VTSpacing.m),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    ReminderHistoryCalendarCard(cubit: cubit, state: state),
                    if (state.selectedDay case final selectedDay?) ...[
                      const VTGap.l(),
                      ReminderDaySection(date: selectedDay, reminders: state.selectedReminders),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

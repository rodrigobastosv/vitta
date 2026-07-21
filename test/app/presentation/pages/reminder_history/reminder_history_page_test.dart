import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  Future<void> pumpHistory(WidgetTester tester, {required Map<DateTime, List<Reminder>> monthReminders}) async {
    final getRange = MockGetRemindersInRangeUseCase();
    when(
      () => getRange(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => Success(monthReminders));
    final cubit = CubitsFactories.buildReminderHistoryCubit(getRemindersInRangeUseCase: getRange);
    G.registerFactory<ReminderHistoryCubit>(() => cubit);
    addTearDown(() => G.unregister<ReminderHistoryCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ReminderHistoryPage(),
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the month calendar once the month has reminders', (tester) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, 15);
    await pumpHistory(
      tester,
      monthReminders: {
        day: [ReminderFactory.build(title: 'Pay rent', dueDate: day)],
      },
    );

    expect(find.byType(VTCalendarMonthGrid), findsOneWidget);
  });

  testWidgets('invites a first reminder instead of showing an empty calendar', (tester) async {
    await pumpHistory(tester, monthReminders: const {});

    expect(find.text('Nothing this month'), findsOneWidget);
    expect(find.text('Create a reminder'), findsOneWidget);
    expect(find.byType(VTCalendarMonthGrid), findsNothing);
  });

  testWidgets('tapping a day with reminders shows that day below the calendar', (tester) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, 15);
    await pumpHistory(
      tester,
      monthReminders: {
        day: [ReminderFactory.build(title: 'Pay rent', dueDate: day)],
      },
    );

    expect(find.text('Pay rent'), findsNothing);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.text('Pay rent'), findsOneWidget);
  });
}

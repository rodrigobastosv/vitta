import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder_day/reminder_day_extra.dart';
import 'package:vitta/app/presentation/pages/reminder_day/reminder_day_page.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  Future<void> pumpHistory(WidgetTester tester, {required Map<DateTime, List<Reminder>> monthReminders}) async {
    final getRange = MockGetRemindersInRangeUseCase();
    when(() => getRange(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(monthReminders));
    final cubit = CubitsFactories.buildReminderHistoryCubit(getRemindersInRangeUseCase: getRange);
    G.registerFactory<ReminderHistoryCubit>(() => cubit);
    addTearDown(() => G.unregister<ReminderHistoryCubit>());

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', name: AppRoute.reminderHistory.name, builder: (_, _) => const ReminderHistoryPage()),
        GoRoute(
          path: '/day',
          name: AppRoute.reminderDay.name,
          builder: (_, state) {
            final extra = state.extra! as ReminderDayExtra;
            return ReminderDayPage(date: extra.date, reminders: extra.reminders);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the month calendar', (tester) async {
    await pumpHistory(tester, monthReminders: const {});

    expect(find.byType(VTCalendarMonthGrid), findsOneWidget);
  });

  testWidgets('tapping a day with reminders opens that day and shows its reminders', (tester) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, 15);
    await pumpHistory(tester, monthReminders: {
      day: [ReminderFactory.build(title: 'Pay rent', dueDate: day)],
    });

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(find.byType(ReminderDayPage), findsOneWidget);
    expect(find.text('Pay rent'), findsOneWidget);
  });
}

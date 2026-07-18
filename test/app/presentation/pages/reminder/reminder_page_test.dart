import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/reminder_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  Future<void> pumpPage(WidgetTester tester, {required List<Reminder> reminders}) async {
    final getReminders = MockGetRemindersForDateUseCase();
    when(() => getReminders(date: any(named: 'date'))).thenAnswer((_) async => Success(reminders));
    final cubit = CubitsFactories.buildReminderCubit(getRemindersForDateUseCase: getReminders);
    G.registerFactory<ReminderCubit>(() => cubit);
    addTearDown(() => G.unregister<ReminderCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ReminderPage(),
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the filter tabs and a tile per reminder', (tester) async {
    await pumpPage(tester, reminders: [ReminderFactory.build(title: 'Pay rent')]);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Pay rent'), findsOneWidget);
  });

  testWidgets('the completed filter hides an active reminder', (tester) async {
    await pumpPage(
      tester,
      reminders: [
        ReminderFactory.build(id: 'a', title: 'Active one'),
        ReminderFactory.build(id: 'b', title: 'Done one', completedAt: DateTime(2026, 7, 18, 9)),
      ],
    );

    expect(find.text('Active one'), findsOneWidget);
    expect(find.text('Done one'), findsOneWidget);

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Active one'), findsNothing);
    expect(find.text('Done one'), findsOneWidget);
  });

  testWidgets('shows the empty state when there is nothing for the day', (tester) async {
    await pumpPage(tester, reminders: const []);

    expect(find.text('No reminders'), findsOneWidget);
  });

  testWidgets('the FAB opens the create form', (tester) async {
    await pumpPage(tester, reminders: const []);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New reminder'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
  });

  testWidgets('the app bar exposes the history action', (tester) async {
    await pumpPage(tester, reminders: const []);

    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
  });
}

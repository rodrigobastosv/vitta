import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_streak_chip.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_week_day_cell.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_week_strip.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';

const _goals = MacroGoals.defaultGoals;

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _daysBefore(int offset) {
  final today = _today();
  return DateTime(today.year, today.month, today.day - offset);
}

DailyMacros _dayOf(double calories) => DailyMacros(
  entries: [FoodLogEntryFactory.build(food: FoodFactory.build(caloriesPer100g: calories))],
);

Future<DateTime?> pumpStrip(
  WidgetTester tester, {
  DateTime? date,
  Map<DateTime, DailyMacros> macrosByDate = const {},
  LoggingStreak streak = LoggingStreak.none,
  Locale locale = const Locale('en'),
  double width = 390,
}) async {
  DateTime? picked;
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(VTSpacing.m),
          child: DietWeekStrip(
            date: date ?? _today(),
            macrosByDate: macrosByDate,
            macroGoals: _goals,
            streak: streak,
            onPickDate: (day) => picked = day,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return picked;
}

void main() {
  testWidgets('it shows a cell for every day of the week', (tester) async {
    await pumpStrip(tester);

    expect(find.byType(DietWeekDayCell), findsNWidgets(7));
  });

  // The dot is the whole "did I log, and how did it go" signal, and it reads off
  // the same GoalAdherence the calendar does.
  testWidgets('a day on target dots green and a day well over dots red', (tester) async {
    await pumpStrip(
      tester,
      macrosByDate: {_today(): _dayOf(_goals.calorieGoal), _daysBefore(1): _dayOf(_goals.calorieGoal * 2)},
    );

    final cells = tester.widgetList<DietWeekDayCell>(find.byType(DietWeekDayCell));
    final onTarget = cells.firstWhere((cell) => cell.date == _today());
    final wellOver = cells.firstWhere((cell) => cell.date == _daysBefore(1));

    expect(onTarget.dotColor, VTColors.green);
    expect(wellOver.dotColor, VTColors.error);
  });

  testWidgets('a day with nothing logged carries no dot colour of its own', (tester) async {
    await pumpStrip(tester);

    final cells = tester.widgetList<DietWeekDayCell>(find.byType(DietWeekDayCell));

    expect(cells.every((cell) => cell.dotColor == null), isTrue);
  });

  testWidgets('a future day cannot be picked', (tester) async {
    await pumpStrip(tester, date: _daysBefore(6));

    final cells = tester.widgetList<DietWeekDayCell>(find.byType(DietWeekDayCell));

    for (final cell in cells) {
      expect(cell.onTap == null, cell.date.isAfter(_today()), reason: 'wrong enablement for ${cell.date}');
    }
  });

  testWidgets('tapping a day reports it', (tester) async {
    final yesterday = _daysBefore(1);
    DateTime? picked;
    await pumpStrip(tester);
    // The callback is captured per pump, so re-pump with a recording closure.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DietWeekStrip(
            date: _today(),
            macrosByDate: const {},
            macroGoals: _goals,
            streak: LoggingStreak.none,
            onPickDate: (day) => picked = day,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('${yesterday.day}'));
    await tester.pumpAndSettle();

    expect(picked, yesterday);
  });

  testWidgets('the streak is shown once there is one, and hidden at zero', (tester) async {
    await pumpStrip(tester, streak: const LoggingStreak(days: 4));
    expect(find.byType(DietStreakChip), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await pumpStrip(tester);
    expect(find.byType(DietStreakChip), findsNothing);
  });

  // It shipped with a Spacer beside a Flexible, which are both flex children, so
  // they split the free space and the chip stopped half way to the edge.
  testWidgets('the streak sits against the right edge of the strip', (tester) async {
    await pumpStrip(tester, streak: const LoggingStreak(days: 4));

    final chipRight = tester.getRect(find.byType(DietStreakChip)).right;
    final stripRight = tester.getRect(find.byType(DietWeekStrip)).right;

    expect(chipRight, moreOrLessEquals(stripRight, epsilon: 0.5));
  });

  testWidgets('a day cell clears the tap-target floor on a phone-width strip', (tester) async {
    await pumpStrip(tester, width: 320);

    for (final cell in find.byType(DietWeekDayCell).evaluate()) {
      final size = tester.getSize(find.byWidget(cell.widget));
      expect(size.height, greaterThanOrEqualTo(VTSpacing.minTapTarget));
      expect(size.width, greaterThanOrEqualTo(VTSpacing.minTapTarget));
    }
  });

  for (final locale in const [Locale('en'), Locale('pt')]) {
    testWidgets('it lays out at 320px in ${locale.languageCode} without overflowing', (tester) async {
      await pumpStrip(tester, streak: const LoggingStreak(days: 128), locale: locale, width: 320);

      expect(tester.takeException(), isNull);
    });
  }
}

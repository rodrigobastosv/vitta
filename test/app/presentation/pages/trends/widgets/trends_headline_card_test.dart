import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/trend_area.dart';
import 'package:vitta/app/presentation/pages/trends/trends_state.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trend_area_chip.dart';
import 'package:vitta/app/presentation/pages/trends/widgets/trends_headline_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

AreaTrend buildAreaTrend({required double average, double? goal}) => AreaTrend(
  days: [DateTime(2026, 7, 20)],
  valuesByDate: {DateTime(2026, 7, 20): average},
  goal: goal,
);

TrendsState buildState({required int onTrack}) => TrendsState(
  trends: {
    .nutrition: buildAreaTrend(average: onTrack >= 1 ? 2000 : 800, goal: 2000),
    .water: buildAreaTrend(average: onTrack >= 2 ? 2000 : 500, goal: 2000),
    .sleep: buildAreaTrend(average: onTrack >= 3 ? 8 : 4, goal: 8),
    .workout: buildAreaTrend(average: 4000),
    .bodyWeight: buildAreaTrend(average: 74),
  },
);

Future<void> pumpHeadline(WidgetTester tester, {required TrendsState state, Locale locale = const Locale('en')}) {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TrendsHeadlineCard(state: state),
      ),
    ),
  );
}

void main() {
  testWidgets('answers on track or not with the count behind it', (tester) async {
    await pumpHeadline(tester, state: buildState(onTrack: 3));

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text("You're on track"), findsOneWidget);
  });

  testWidgets('a partial score reads as mostly on track', (tester) async {
    await pumpHeadline(tester, state: buildState(onTrack: 2));

    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('Mostly on track'), findsOneWidget);
  });

  testWidgets('says there is nothing to judge when no goal area has data', (tester) async {
    await pumpHeadline(tester, state: const TrendsState());

    expect(find.text('Nothing to judge yet'), findsOneWidget);
  });

  testWidgets('chips every area that has data, judged or not', (tester) async {
    await pumpHeadline(tester, state: buildState(onTrack: 3));

    expect(find.byType(TrendAreaChip), findsNWidgets(TrendArea.values.length));
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('lays out on a narrow phone in ${locale.languageCode}', (tester) async {
      await pumpHeadline(tester, state: buildState(onTrack: 1), locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}

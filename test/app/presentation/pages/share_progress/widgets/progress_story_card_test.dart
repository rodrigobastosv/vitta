import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_story_card.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/presentation/pages/share_progress/widgets/progress_story_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

AreaTrend buildAreaTrend({required double average, double? previousAverage, double? goal}) => AreaTrend(
  days: [DateTime(2026, 7, 20)],
  valuesByDate: {DateTime(2026, 7, 20): average},
  previousValuesByDate: {DateTime(2026, 6, 20): ?previousAverage},
  goal: goal,
);

ProgressStory buildStory({int onTrack = 3}) => ProgressStory(
  days: 30,
  trends: {
    .nutrition: buildAreaTrend(average: onTrack >= 1 ? 2000 : 800, previousAverage: 1800, goal: 2000),
    .water: buildAreaTrend(average: onTrack >= 2 ? 2000 : 500, previousAverage: 2400, goal: 2000),
    .sleep: buildAreaTrend(average: onTrack >= 3 ? 8 : 4, previousAverage: 8, goal: 8),
    .workout: buildAreaTrend(average: 4200, previousAverage: 3500),
    .bodyWeight: buildAreaTrend(average: 74.4, previousAverage: 75.9),
  },
);

Future<void> pumpStoryCard(
  WidgetTester tester, {
  required ProgressStory story,
  Locale locale = const Locale('en'),
  Brightness brightness = .light,
}) {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: brightness == .dark ? VTTheme.dark : VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: FittedBox(child: ProgressStoryCard(story: story, unitSystem: .metric)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('states the period, the verdict and the goals behind it', (tester) async {
    await pumpStoryCard(tester, story: buildStory());

    expect(find.text('Vitta'), findsOneWidget);
    expect(find.text('Last 30 days'), findsOneWidget);
    expect(find.text("You're on track"), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('names a period with no goal to judge rather than admitting nothing to judge', (tester) async {
    await pumpStoryCard(tester, story: ProgressStory(days: 7, trends: {.workout: buildAreaTrend(average: 4200)}));

    expect(find.text('My progress'), findsOneWidget);
    expect(find.text('Nothing to judge yet'), findsNothing);
  });

  testWidgets('lists one figure per area that has data, with its change', (tester) async {
    await pumpStoryCard(tester, story: buildStory());

    expect(find.text('2000 kcal'), findsOneWidget);
    expect(find.text('+11%'), findsOneWidget);
    expect(find.text('−17%'), findsOneWidget);
  });

  testWidgets('exports at a fixed 9:16 whatever the screen it was rendered on', (tester) async {
    await pumpStoryCard(tester, story: buildStory());

    expect(tester.getSize(find.byType(VTStoryCard)), const Size(VTStoryCard.width, VTStoryCard.height));
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    for (final brightness in Brightness.values) {
      testWidgets('lays out on a narrow phone in ${locale.languageCode} on ${brightness.name}', (tester) async {
        await pumpStoryCard(tester, story: buildStory(onTrack: 1), locale: locale, brightness: brightness);

        expect(tester.takeException(), isNull);
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_water_fill.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';
import 'package:vitta/app/presentation/pages/water/widgets/water_progress_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/water_log_factory.dart';

Future<void> pumpCard(WidgetTester tester, {required DailyWater dailyWater, double goalMl = 2000, Locale locale = const Locale('en')}) {
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
        body: WaterProgressCard(
          dailyWater: dailyWater,
          dailyGoalMl: goalMl,
          unitSystem: UnitSystem.metric,
          onQuickAdd: (_) {},
          onEditGoal: () {},
        ),
      ),
    ),
  );
}

DailyWater dailyWater(List<double> amounts) => DailyWater(entries: [for (final (index, amount) in amounts.indexed) WaterLogFactory.build(id: 'log-$index', amountMl: amount)]);

void main() {
  testWidgets('renders the fill visual instead of a ring', (tester) async {
    await pumpCard(tester, dailyWater: dailyWater([500, 750]));
    await tester.pump();

    expect(find.byType(VTWaterFill), findsOneWidget);
  });

  testWidgets('shows the remaining amount below the goal', (tester) async {
    await pumpCard(tester, dailyWater: dailyWater([500]));
    await tester.pump();

    expect(find.text('1500 mL left'), findsOneWidget);
  });

  testWidgets('announces the goal is reached once it is met', (tester) async {
    await pumpCard(tester, dailyWater: dailyWater([1200, 1000]));
    await tester.pump();

    expect(find.text('Goal reached!'), findsOneWidget);
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('lays out on a narrow phone in ${locale.languageCode}', (tester) async {
      await pumpCard(tester, dailyWater: dailyWater([1250]), locale: locale);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }
}

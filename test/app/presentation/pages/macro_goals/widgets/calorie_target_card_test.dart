import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/calorie_target_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/entities/macro_goals_factory.dart';

Future<void> pumpCard(WidgetTester tester, {Locale locale = const Locale('en')}) {
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CalorieTargetCard(goals: MacroGoalsFactory.build(), onCaloriesChanged: (_) {}),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the derived target without overflowing at 320px', (tester) async {
    await pumpCard(tester);

    expect(find.text('2185 kcal'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow in Portuguese too', (tester) async {
    await pumpCard(tester, locale: const Locale('pt'));

    expect(tester.takeException(), isNull);
  });

  testWidgets('the calorie slider reports the rescaled total', (tester) async {
    double? reported;
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CalorieTargetCard(goals: MacroGoalsFactory.build(), onCaloriesChanged: (calories) => reported = calories),
        ),
      ),
    );

    await tester.tap(find.byType(Slider));
    await tester.pump();

    expect(reported, isNotNull);
  });
}

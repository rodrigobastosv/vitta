import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_card.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/diet_modality_selector.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpSelector(
  WidgetTester tester, {
  required DietModality? selected,
  required ValueChanged<DietModality> onSelected,
  Locale locale = const Locale('en'),
  double width = 320,
}) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DietModalitySelector(selected: selected, onSelected: onSelected),
      ),
    ),
  );
}

Future<void> expandSelector(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.expand_more));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts collapsed, showing no cards and the current pick', (tester) async {
    await pumpSelector(tester, selected: DietModality.lowFat, onSelected: (_) {});

    expect(find.byType(DietModalityCard), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(find.text('Low fat'), findsOneWidget);
  });

  testWidgets('expanding reveals one card per modality without overflow', (tester) async {
    await pumpSelector(tester, selected: DietModality.balanced, onSelected: (_) {}, width: 900);

    await expandSelector(tester);

    expect(find.byType(DietModalityCard), findsNWidgets(DietModality.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow at a narrow 320px width', (tester) async {
    await pumpSelector(tester, selected: DietModality.balanced, onSelected: (_) {});

    await expandSelector(tester);

    expect(find.byType(DietModalityCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow in Portuguese too', (tester) async {
    await pumpSelector(tester, selected: null, onSelected: (_) {}, locale: const Locale('pt'));

    await expandSelector(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a card reports its modality', (tester) async {
    DietModality? picked;
    await pumpSelector(tester, selected: DietModality.balanced, onSelected: (modality) => picked = modality, width: 900);
    await expandSelector(tester);

    await tester.tap(find.text('Low fat'));
    await tester.pump();

    expect(picked, DietModality.lowFat);
  });

  testWidgets('each modality card shows its own icon', (tester) async {
    await pumpSelector(tester, selected: DietModality.balanced, onSelected: (_) {}, width: 900);

    await expandSelector(tester);

    expect(find.byIcon(Icons.balance), findsOneWidget);
    expect(find.byIcon(Icons.egg_alt), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('the selected card carries no check icon', (tester) async {
    await pumpSelector(tester, selected: DietModality.balanced, onSelected: (_) {}, width: 900);

    await expandSelector(tester);

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('collapsing again hides the cards', (tester) async {
    await pumpSelector(tester, selected: DietModality.lowFat, onSelected: (_) {}, width: 900);
    await expandSelector(tester);
    expect(find.byType(DietModalityCard), findsWidgets);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    expect(find.byType(DietModalityCard), findsNothing);
  });

  testWidgets('the collapsed summary reads Custom for a custom split', (tester) async {
    await pumpSelector(tester, selected: null, onSelected: (_) {});

    expect(find.text('Custom'), findsOneWidget);
  });
}

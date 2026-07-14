import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_page.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_selection_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

final sourceDate = DateTime(2026, 7, 10);
final targetDate = DateTime(2026, 7, 14);

Widget buildTestApp({required CopyMealsCubit cubit, void Function({bool? hasCopied})? onPopped}) {
  if (G.isRegistered<CopyMealsCubit>()) {
    G.unregister<CopyMealsCubit>();
  }
  G.registerFactory<CopyMealsCubit>(() => cubit);
  return MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final hasCopied = await Navigator.of(
                context,
              ).push<bool>(MaterialPageRoute(builder: (_) => CopyMealsPage(targetDate: targetDate)));
              onPopped?.call(hasCopied: hasCopied);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
    builder: (context, child) => LoaderOverlay(child: child!),
  );
}

// The page stacks a month calendar over the meal list; the default 800px test
// viewport cuts the list off, and a ListView never builds what it can't show —
// which would make every `findsNothing` below pass for the wrong reason.
Future<void> pumpCopyMealsPage(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1200, 4200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<FoodLogEntry>[]);
  });

  CopyMealsCubit buildCubit({MockCopyFoodLogsUseCase? copyFoodLogsUseCase, Map<DateTime, DailyMacros>? macrosByDate}) {
    final getMacrosInRangeUseCase = MockGetMacrosInRangeUseCase();
    when(
      () => getMacrosInRangeUseCase(from: any(named: 'from'), to: any(named: 'to')),
    ).thenAnswer((_) async => Success(macrosByDate ?? const {}));
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    return CubitsFactories.buildCopyMealsCubit(
      getMacrosInRangeUseCase: getMacrosInRangeUseCase,
      getMacroGoalsUseCase: getMacroGoalsUseCase,
      copyFoodLogsUseCase: copyFoodLogsUseCase ?? MockCopyFoodLogsUseCase(),
      targetDate: targetDate,
    );
  }

  Map<DateTime, DailyMacros> aDayWithBreakfastAndLunch() => {
    sourceDate: DailyMacros(
      entries: [
        FoodLogEntryFactory.build(log: FoodLogFactory.build()),
        FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'log-2', mealType: MealType.lunch)),
      ],
    ),
  };

  testWidgets('asks for a source day before offering anything to copy', (tester) async {
    await pumpCopyMealsPage(tester, buildTestApp(cubit: buildCubit(macrosByDate: aDayWithBreakfastAndLunch())));

    expect(find.byType(VTEmptyState), findsOneWidget);
    expect(find.byType(CopyMealsSelectionCard), findsNothing);
    expect(tester.widget<VTPrimaryButton>(find.byType(VTPrimaryButton)).onPressed, isNull);
  });

  testWidgets('picking a day lists its meals ticked and enables copying', (tester) async {
    await pumpCopyMealsPage(tester, buildTestApp(cubit: buildCubit(macrosByDate: aDayWithBreakfastAndLunch())));

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(find.byType(CopyMealsSelectionCard), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(tester.widgetList<Checkbox>(find.byType(Checkbox)).every((checkbox) => checkbox.value!), isTrue);
    expect(tester.widget<VTPrimaryButton>(find.byType(VTPrimaryButton)).onPressed, isNotNull);
  });

  testWidgets('a day with nothing logged cannot be picked as a source', (tester) async {
    await pumpCopyMealsPage(tester, buildTestApp(cubit: buildCubit(macrosByDate: aDayWithBreakfastAndLunch())));

    await tester.tap(find.text('11'));
    await tester.pumpAndSettle();

    expect(find.byType(CopyMealsSelectionCard), findsNothing);
  });

  testWidgets('the target day itself cannot be picked as a source', (tester) async {
    await pumpCopyMealsPage(
      tester,
      buildTestApp(
        cubit: buildCubit(
          macrosByDate: {
            ...aDayWithBreakfastAndLunch(),
            targetDate: DailyMacros(entries: [FoodLogEntryFactory.build()]),
          },
        ),
      ),
    );

    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();

    expect(find.byType(CopyMealsSelectionCard), findsNothing);
  });

  testWidgets('unticking a meal leaves the other one copyable', (tester) async {
    final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
    when(
      () => copyFoodLogsUseCase(entries: any(named: 'entries'), targetDate: any(named: 'targetDate')),
    ).thenAnswer((_) async => const Success(null));
    await pumpCopyMealsPage(
      tester,
      buildTestApp(
        cubit: buildCubit(copyFoodLogsUseCase: copyFoodLogsUseCase, macrosByDate: aDayWithBreakfastAndLunch()),
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VTPrimaryButton));
    await tester.pumpAndSettle();

    final entries = verify(
      () => copyFoodLogsUseCase(entries: captureAny(named: 'entries'), targetDate: targetDate),
    ).captured.single as List<FoodLogEntry>;
    expect(entries.map((entry) => entry.log.mealType), [MealType.lunch]);
  });

  testWidgets('a successful copy toasts and pops back so the diet page can refresh', (tester) async {
    final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
    when(
      () => copyFoodLogsUseCase(entries: any(named: 'entries'), targetDate: any(named: 'targetDate')),
    ).thenAnswer((_) async => const Success(null));
    bool? poppedWith;
    await pumpCopyMealsPage(
      tester,
      buildTestApp(
        cubit: buildCubit(copyFoodLogsUseCase: copyFoodLogsUseCase, macrosByDate: aDayWithBreakfastAndLunch()),
        onPopped: ({hasCopied}) => poppedWith = hasCopied,
      ),
    );

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VTPrimaryButton));
    await tester.pumpAndSettle();

    expect(poppedWith, isTrue);
    expect(find.text('2 meals added to your day'), findsOneWidget);
  });
}

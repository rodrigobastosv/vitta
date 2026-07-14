import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/edit_food_log_sheet.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/cubits_factories.dart';
import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';
import '../../../../../factories/entities/macro_goals_factory.dart';
import '../../../../../mocks/use_cases_mocks.dart';

Future<void> pumpEditSheet(WidgetTester tester, {required DietCubit cubit, required FoodLogEntry entry}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<DietCubit>.value(
        value: cubit,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showEditFoodLogSheet(context: context, entry: entry),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

DietCubit buildCubit({
  required MockUpdateFoodLogUseCase updateFoodLogUseCase,
  UnitSystem unitSystem = UnitSystem.metric,
}) {
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  final getDailyMacrosUseCase = MockGetDailyMacrosUseCase();
  final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(AppSettings(unitSystem: unitSystem));
  when(() => getDailyMacrosUseCase(date: any(named: 'date'))).thenAnswer((_) async => const Success(DailyMacros(entries: [])));
  when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
  return CubitsFactories.buildDietCubit(
    getDailyMacrosUseCase: getDailyMacrosUseCase,
    updateFoodLogUseCase: updateFoodLogUseCase,
    getMacroGoalsUseCase: getMacroGoalsUseCase,
    getAppSettingsUseCase: getAppSettingsUseCase,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(MealType.breakfast);
  });

  testWidgets('prefills the food, its quantity and the meal it belongs to', (tester) async {
    final entry = FoodLogEntryFactory.build(
      food: FoodFactory.build(name: 'Oatmeal'),
      log: FoodLogFactory.build(mealType: .dinner, quantityGrams: 250),
    );
    await pumpEditSheet(tester, cubit: buildCubit(updateFoodLogUseCase: MockUpdateFoodLogUseCase()), entry: entry);

    expect(find.text('Oatmeal'), findsOneWidget);
    expect(find.widgetWithText(TextField, '250'), findsOneWidget);
    final dinnerChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Dinner'));
    expect(dinnerChip.selected, isTrue);
  });

  testWidgets('saving a new quantity and meal updates the log and closes the sheet', (tester) async {
    final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
    when(
      () => updateFoodLogUseCase(logId: 'log-1', mealType: .lunch, quantityGrams: 180),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));
    await pumpEditSheet(
      tester,
      cubit: buildCubit(updateFoodLogUseCase: updateFoodLogUseCase),
      entry: FoodLogEntryFactory.build(),
    );

    await tester.enterText(find.byType(TextField), '180');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Lunch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => updateFoodLogUseCase(logId: 'log-1', mealType: .lunch, quantityGrams: 180)).called(1);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('a quantity of zero is rejected inline without touching the use case', (tester) async {
    final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
    await pumpEditSheet(
      tester,
      cubit: buildCubit(updateFoodLogUseCase: updateFoodLogUseCase),
      entry: FoodLogEntryFactory.build(),
    );

    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a quantity greater than zero.'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    verifyNever(
      () => updateFoodLogUseCase(logId: any(named: 'logId'), mealType: any(named: 'mealType'), quantityGrams: any(named: 'quantityGrams')),
    );
  });

  testWidgets('an imperial user edits in ounces and the log is still saved in grams', (tester) async {
    final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
    when(
      () => updateFoodLogUseCase(
        logId: any(named: 'logId'),
        mealType: any(named: 'mealType'),
        quantityGrams: any(named: 'quantityGrams'),
      ),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));
    await pumpEditSheet(
      tester,
      cubit: buildCubit(updateFoodLogUseCase: updateFoodLogUseCase, unitSystem: UnitSystem.imperial),
      entry: FoodLogEntryFactory.build(log: FoodLogFactory.build(quantityGrams: 283.495)),
    );

    expect(find.widgetWithText(TextField, '10'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final capturedGrams = verify(
      () => updateFoodLogUseCase(
        logId: any(named: 'logId'),
        mealType: any(named: 'mealType'),
        quantityGrams: captureAny(named: 'quantityGrams'),
      ),
    ).captured.single;
    expect(capturedGrams, closeTo(56.699, 0.001));
  });

  testWidgets('a failed update keeps the sheet open and shows the error inline', (tester) async {
    final updateFoodLogUseCase = MockUpdateFoodLogUseCase();
    when(
      () => updateFoodLogUseCase(logId: 'log-1', mealType: .breakfast, quantityGrams: 100),
    ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    await pumpEditSheet(
      tester,
      cubit: buildCubit(updateFoodLogUseCase: updateFoodLogUseCase),
      entry: FoodLogEntryFactory.build(),
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}

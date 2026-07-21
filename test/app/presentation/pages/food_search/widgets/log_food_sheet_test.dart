import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/log_food_sheet.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../../factories/cubits_factories.dart';
import '../../../../../factories/entities/food_factory.dart';
import '../../../../../factories/entities/food_log_factory.dart';
import '../../../../../mocks/use_cases_mocks.dart';

final _weightField = find.byWidgetPredicate((widget) => widget is TextField && (widget.decoration?.labelText?.startsWith('Quantity') ?? false));
final _unitsField = find.descendant(of: find.byType(VTStepper), matching: find.byType(TextField));

FoodSearchCubit _buildCubit({required MockLogFoodUseCase logFoodUseCase}) {
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  return CubitsFactories.buildFoodSearchCubit(logFoodUseCase: logFoodUseCase, getAppSettingsUseCase: getAppSettingsUseCase);
}

Future<void> _pumpSheet(WidgetTester tester, {required FoodSearchCubit cubit, required Food food}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<FoodSearchCubit>.value(
        value: cubit,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showLogFoodSheet(context: context, food: food, loggedDate: DateTime(2026, 7, 18)),
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

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(MealType.breakfast);
    registerFallbackValue(FoodFactory.build());
  });

  testWidgets('a countable food defaults to one unit and shows its equivalent weight', (tester) async {
    await _pumpSheet(
      tester,
      cubit: _buildCubit(logFoodUseCase: MockLogFoodUseCase()),
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
    );

    expect(tester.widget<TextField>(_unitsField).controller?.text, '1');
    expect(tester.widget<TextField>(_weightField).controller?.text, '50');
  });

  testWidgets('the units stepper sits to the left of the weight field', (tester) async {
    await _pumpSheet(
      tester,
      cubit: _buildCubit(logFoodUseCase: MockLogFoodUseCase()),
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
    );

    expect(tester.getTopLeft(find.byType(VTStepper)).dx, lessThan(tester.getTopLeft(_weightField).dx));
  });

  testWidgets('a food nobody counts still defaults to one hundred grams', (tester) async {
    await _pumpSheet(
      tester,
      cubit: _buildCubit(logFoodUseCase: MockLogFoodUseCase()),
      food: FoodFactory.build(name: 'Arroz'),
    );

    expect(find.byType(VTStepper), findsNothing);
    expect(tester.widget<TextField>(_weightField).controller?.text, '100');
  });

  testWidgets('logging the default countable food records one unit', (tester) async {
    final logFoodUseCase = MockLogFoodUseCase();
    when(
      () => logFoodUseCase(
        food: any(named: 'food'),
        loggedDate: any(named: 'loggedDate'),
        mealType: any(named: 'mealType'),
        quantityGrams: any(named: 'quantityGrams'),
        quantityUnits: any(named: 'quantityUnits'),
      ),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));

    await _pumpSheet(
      tester,
      cubit: _buildCubit(logFoodUseCase: logFoodUseCase),
      food: FoodFactory.build(name: 'Ovo', gramsPerUnit: 50),
    );

    await tester.tap(find.text('Add to day'));
    await tester.pumpAndSettle();

    verify(
      () => logFoodUseCase(
        food: any(named: 'food'),
        loggedDate: any(named: 'loggedDate'),
        mealType: any(named: 'mealType'),
        quantityGrams: 50,
        quantityUnits: 1,
      ),
    ).called(1);
  });
}

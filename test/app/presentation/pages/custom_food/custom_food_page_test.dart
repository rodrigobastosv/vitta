import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

Widget buildTestApp({required CustomFoodCubit cubit, void Function(Food? food)? onPopped}) {
  if (G.isRegistered<CustomFoodCubit>()) {
    G.unregister<CustomFoodCubit>();
  }
  G.registerFactory<CustomFoodCubit>(() => cubit);
  return MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final food = await Navigator.of(context).push<Food>(MaterialPageRoute(builder: (_) => const CustomFoodPage()));
              onPopped?.call(food);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
    builder: (context, child) => LoaderOverlay(child: child!),
  );
}

Future<void> openCustomFoodPage(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the photo header, the text fields and a field per nutrient', (tester) async {
    await tester.pumpWidget(buildTestApp(cubit: CubitsFactories.buildCustomFoodCubit()));
    await openCustomFoodPage(tester);

    expect(find.text('Add a photo'), findsOneWidget);
    expect(find.text('Scan nutrition label'), findsOneWidget);
    for (final label in ['Name', 'Brand (optional)', 'Calories', 'Protein', 'Carbs', 'Fat', 'Fiber']) {
      expect(find.widgetWithText(TextField, label), findsOneWidget);
    }
  });

  testWidgets('shows the energy split only once a macro is typed', (tester) async {
    await tester.pumpWidget(buildTestApp(cubit: CubitsFactories.buildCustomFoodCubit()));
    await openCustomFoodPage(tester);

    expect(find.text('Energy split'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Protein'), '10');
    await tester.pumpAndSettle();

    expect(find.text('Energy split'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('a scanned label fills the nutrient fields', (tester) async {
    final imagePickerService = MockImagePickerService();
    final scanNutritionLabelUseCase = MockScanNutritionLabelUseCase();
    when(
      () => imagePickerService.pickImage(
        source: .gallery,
        maxWidth: any(named: 'maxWidth'),
      ),
    ).thenAnswer((_) async => PickedImage(path: '/tmp/label.jpg', bytes: Uint8List.fromList([1]), fileExtension: 'jpg'));
    when(
      () => scanNutritionLabelUseCase(imagePath: '/tmp/label.jpg'),
    ).thenAnswer((_) async => const Success(ScannedNutritionFacts(caloriesPer100g: 200, proteinPer100g: 10.5)));
    await tester.pumpWidget(
      buildTestApp(
        cubit: CubitsFactories.buildCustomFoodCubit(
          imagePickerService: imagePickerService,
          scanNutritionLabelUseCase: scanNutritionLabelUseCase,
        ),
      ),
    );
    await openCustomFoodPage(tester);

    await tester.ensureVisible(find.text('Scan nutrition label'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan nutrition label'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '200'), findsOneWidget);
    expect(find.widgetWithText(TextField, '10.5'), findsOneWidget);
  });

  testWidgets('continuing with a missing macro keeps the page open and explains why', (tester) async {
    await tester.pumpWidget(buildTestApp(cubit: CubitsFactories.buildCustomFoodCubit()));
    await openCustomFoodPage(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Greek yogurt');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Fill in the name and all macros with valid numbers.'), findsOneWidget);
    expect(find.text('Almost there'), findsOneWidget);
    expect(find.byType(CustomFoodPage), findsOneWidget);
  });

  testWidgets('continuing with a complete form pops the built custom food back', (tester) async {
    Food? poppedFood;
    await tester.pumpWidget(buildTestApp(cubit: CubitsFactories.buildCustomFoodCubit(), onPopped: (food) => poppedFood = food));
    await openCustomFoodPage(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Greek yogurt');
    await tester.enterText(find.widgetWithText(TextField, 'Brand (optional)'), 'Fage');
    for (final (label, value) in [('Calories', '97'), ('Protein', '10'), ('Carbs', '4'), ('Fat', '5'), ('Fiber', '0')]) {
      await tester.enterText(find.widgetWithText(TextField, label), value);
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(poppedFood?.name, 'Greek yogurt');
    expect(poppedFood?.brand, 'Fage');
    expect(poppedFood?.caloriesPer100g, 97);
    expect(poppedFood?.proteinPer100g, 10);
    expect(find.text('open'), findsOneWidget);
  });
}

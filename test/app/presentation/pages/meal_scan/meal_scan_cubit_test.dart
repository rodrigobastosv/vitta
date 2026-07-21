import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

ScannedMealItem _item(String name) =>
    ScannedMealItem(name: name, estimatedGrams: 150, caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 5, fatPer100g: 2);

MockImagePickerService _pickerReturning(PickedImage image) {
  final imagePickerService = MockImagePickerService();
  when(
    () => imagePickerService.pickImage(
      source: .camera,
      maxWidth: any(named: 'maxWidth'),
    ),
  ).thenAnswer((_) async => image);
  return imagePickerService;
}

void main() {
  setUpAll(() {
    registerFallbackValue(<ScannedMealLogItem>[]);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(MealType.lunch);
  });

  final pickedMeal = PickedImage(path: '/tmp/meal.jpg', bytes: Uint8List.fromList([1, 2]), fileExtension: 'jpg');

  blocTest<MealScanCubit, MealScanState>(
    'scanMeal stores the photo and populates entries from the detected items',
    build: () {
      final scanMealUseCase = MockScanMealUseCase();
      when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => Success(ScannedMeal(items: [_item('Rice'), _item('Chicken')])));
      return CubitsFactories.buildMealScanCubit(imagePickerService: _pickerReturning(pickedMeal), scanMealUseCase: scanMealUseCase);
    },
    act: (cubit) => cubit.scanMeal(source: .camera),
    expect: () => [
      isA<MealScanState>().having((state) => state.imageBytes, 'imageBytes', Uint8List.fromList([1, 2])),
      isA<MealScanState>()
          .having((state) => state.hasScanned, 'hasScanned', isTrue)
          .having((state) => state.entries.map((entry) => entry.item.name).toList(), 'names', ['Rice', 'Chicken'])
          .having((state) => state.entries.first.gramsText, 'first grams', '150'),
    ],
  );

  blocPresentationTest<MealScanCubit, MealScanState, MealScanPresentationEvent>(
    'scanMeal emits loading events and MealScanFoundNothing when nothing is detected',
    build: () {
      final scanMealUseCase = MockScanMealUseCase();
      when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => const Success(ScannedMeal(items: [])));
      return CubitsFactories.buildMealScanCubit(imagePickerService: _pickerReturning(pickedMeal), scanMealUseCase: scanMealUseCase);
    },
    act: (cubit) => cubit.scanMeal(source: .camera),
    expectPresentation: () => [isA<MealScanShowLoading>(), isA<MealScanHideLoading>(), isA<MealScanFoundNothing>()],
  );

  blocPresentationTest<MealScanCubit, MealScanState, MealScanPresentationEvent>(
    'scanMeal emits MealScanError when the scan fails',
    build: () {
      final scanMealUseCase = MockScanMealUseCase();
      when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildMealScanCubit(imagePickerService: _pickerReturning(pickedMeal), scanMealUseCase: scanMealUseCase);
    },
    act: (cubit) => cubit.scanMeal(source: .camera),
    expectPresentation: () => [
      isA<MealScanShowLoading>(),
      isA<MealScanHideLoading>(),
      isA<MealScanError>().having((event) => event.message, 'message', 'boom'),
    ],
  );

  test('gramsChanged updates the amount and toggleIncluded excludes an item', () async {
    final scanMealUseCase = MockScanMealUseCase();
    when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => Success(ScannedMeal(items: [_item('Rice'), _item('Chicken')])));
    final cubit = CubitsFactories.buildMealScanCubit(imagePickerService: _pickerReturning(pickedMeal), scanMealUseCase: scanMealUseCase);

    await cubit.scanMeal(source: .camera);
    cubit.gramsChanged(index: 0, text: '250');
    cubit.toggleIncluded(index: 1);

    expect(cubit.state.entries[0].gramsText, '250');
    expect(cubit.state.entries[1].isIncluded, isFalse);
    expect(cubit.state.includedEntries, hasLength(1));
  });

  test('canLog is false once an included item has an invalid amount', () async {
    final scanMealUseCase = MockScanMealUseCase();
    when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => Success(ScannedMeal(items: [_item('Rice')])));
    final cubit = CubitsFactories.buildMealScanCubit(imagePickerService: _pickerReturning(pickedMeal), scanMealUseCase: scanMealUseCase);

    await cubit.scanMeal(source: .camera);
    expect(cubit.state.canLog, isTrue);

    cubit.gramsChanged(index: 0, text: '');
    expect(cubit.state.canLog, isFalse);
  });

  blocPresentationTest<MealScanCubit, MealScanState, MealScanPresentationEvent>(
    'logMeal emits MealScanIncomplete when there is nothing valid to log',
    build: CubitsFactories.buildMealScanCubit,
    act: (cubit) => cubit.logMeal(),
    expectPresentation: () => [isA<MealScanIncomplete>()],
  );

  final logScannedMealUseCase = MockLogScannedMealUseCase();
  blocPresentationTest<MealScanCubit, MealScanState, MealScanPresentationEvent>(
    'logMeal logs only the included items and emits MealScanLogged',
    build: () {
      final scanMealUseCase = MockScanMealUseCase();
      when(() => scanMealUseCase(imagePath: '/tmp/meal.jpg')).thenAnswer((_) async => Success(ScannedMeal(items: [_item('Rice'), _item('Chicken')])));
      when(
        () => logScannedMealUseCase(
          items: any(named: 'items'),
          loggedDate: any(named: 'loggedDate'),
          mealType: any(named: 'mealType'),
        ),
      ).thenAnswer((_) async => const Success(null));
      return CubitsFactories.buildMealScanCubit(
        imagePickerService: _pickerReturning(pickedMeal),
        scanMealUseCase: scanMealUseCase,
        logScannedMealUseCase: logScannedMealUseCase,
      );
    },
    act: (cubit) async {
      await cubit.scanMeal(source: .camera);
      cubit.mealTypeChanged(MealType.dinner);
      cubit.toggleIncluded(index: 1);
      await cubit.logMeal();
    },
    expectPresentation: () => [
      isA<MealScanShowLoading>(),
      isA<MealScanHideLoading>(),
      isA<MealScanShowLoading>(),
      isA<MealScanHideLoading>(),
      isA<MealScanLogged>().having((event) => event.mealType, 'mealType', MealType.dinner).having((event) => event.itemCount, 'itemCount', 1),
    ],
    verify: (_) {
      final captured =
          verify(
                () => logScannedMealUseCase(
                  items: captureAny(named: 'items'),
                  loggedDate: any(named: 'loggedDate'),
                  mealType: MealType.dinner,
                ),
              ).captured.single
              as List<ScannedMealLogItem>;
      expect(captured.map((logItem) => logItem.item.name), ['Rice']);
    },
  );
}

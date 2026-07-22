import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void fillEveryNutrient(CustomFoodCubit cubit) {
  cubit.nameChanged('Greek yogurt');
  for (final nutrient in CustomFoodNutrient.values) {
    cubit.nutrientChanged(nutrient: nutrient, text: '10');
  }
}

void main() {
  test('nutrientChanged parses a comma decimal into the nutrient map', () {
    final cubit = CubitsFactories.buildCustomFoodCubit();

    cubit.nutrientChanged(nutrient: .protein, text: '3,5');

    expect(cubit.state.nutrients[CustomFoodNutrient.protein], 3.5);
  });

  test('nutrientChanged drops the nutrient when the text is not a number', () {
    final cubit = CubitsFactories.buildCustomFoodCubit();
    cubit.nutrientChanged(nutrient: .protein, text: '3.5');

    cubit.nutrientChanged(nutrient: .protein, text: '');

    expect(cubit.state.nutrients.containsKey(CustomFoodNutrient.protein), isFalse);
  });

  test('isComplete only once the name and every nutrient are filled', () {
    final cubit = CubitsFactories.buildCustomFoodCubit();
    cubit.nameChanged('Greek yogurt');
    cubit.nutrientChanged(nutrient: .calories, text: '97');

    expect(cubit.state.isComplete, isFalse);

    fillEveryNutrient(cubit);

    expect(cubit.state.isComplete, isTrue);
  });

  blocTest<CustomFoodCubit, CustomFoodState>(
    'pickPhoto stores the picked bytes and extension',
    build: () {
      final imagePickerService = MockImagePickerService();
      when(
        () => imagePickerService.pickImage(
          source: .gallery,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/food.png', bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'png'));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService);
    },
    act: (cubit) => cubit.pickPhoto(source: .gallery),
    expect: () => [
      isA<CustomFoodState>()
          .having((state) => state.imageBytes, 'imageBytes', Uint8List.fromList([1, 2, 3]))
          .having((state) => state.imageExtension, 'imageExtension', 'png'),
    ],
  );

  blocTest<CustomFoodCubit, CustomFoodState>(
    'pickPhoto keeps the state untouched when the user cancels the picker',
    build: () {
      final imagePickerService = MockImagePickerService();
      when(
        () => imagePickerService.pickImage(
          source: .camera,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => null);
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService);
    },
    act: (cubit) => cubit.pickPhoto(source: .camera),
    expect: () => <CustomFoodState>[],
  );

  blocTest<CustomFoodCubit, CustomFoodState>(
    'scanNutritionLabel fills the scanned nutrients and keeps the ones it did not read',
    build: () {
      final imagePickerService = MockImagePickerService();
      final scanNutritionLabelUseCase = MockScanNutritionLabelUseCase();
      when(
        () => imagePickerService.pickImage(
          source: .camera,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/label.jpg', bytes: Uint8List.fromList([1]), fileExtension: 'jpg'));
      when(
        () => scanNutritionLabelUseCase(imagePath: '/tmp/label.jpg'),
      ).thenAnswer((_) async => const Success(ScannedNutritionFacts(caloriesPer100g: 200, proteinPer100g: 10)));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService, scanNutritionLabelUseCase: scanNutritionLabelUseCase);
    },
    act: (cubit) async {
      cubit.nutrientChanged(nutrient: .fiber, text: '2');
      await cubit.scanNutritionLabel(source: .camera);
    },
    skip: 1,
    expect: () => [
      isA<CustomFoodState>().having((state) => state.nutrients, 'nutrients', {
        CustomFoodNutrient.fiber: 2.0,
        CustomFoodNutrient.calories: 200.0,
        CustomFoodNutrient.protein: 10.0,
      }),
    ],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'scanNutritionLabel emits CustomFoodScanFoundNothing when the label has no readable value',
    build: () {
      final imagePickerService = MockImagePickerService();
      final scanNutritionLabelUseCase = MockScanNutritionLabelUseCase();
      when(
        () => imagePickerService.pickImage(
          source: .camera,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/label.jpg', bytes: Uint8List.fromList([1]), fileExtension: 'jpg'));
      when(() => scanNutritionLabelUseCase(imagePath: '/tmp/label.jpg')).thenAnswer((_) async => const Success(ScannedNutritionFacts()));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService, scanNutritionLabelUseCase: scanNutritionLabelUseCase);
    },
    act: (cubit) => cubit.scanNutritionLabel(source: .camera),
    expectPresentation: () => [isA<CustomFoodScanning>(), isA<CustomFoodHideLoading>(), isA<CustomFoodScanFoundNothing>()],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'scanNutritionLabel emits CustomFoodError when the scan fails',
    build: () {
      final imagePickerService = MockImagePickerService();
      final scanNutritionLabelUseCase = MockScanNutritionLabelUseCase();
      when(
        () => imagePickerService.pickImage(
          source: .camera,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/label.jpg', bytes: Uint8List.fromList([1]), fileExtension: 'jpg'));
      when(() => scanNutritionLabelUseCase(imagePath: '/tmp/label.jpg')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService, scanNutritionLabelUseCase: scanNutritionLabelUseCase);
    },
    act: (cubit) => cubit.scanNutritionLabel(source: .camera),
    expectPresentation: () => [
      isA<CustomFoodScanning>(),
      isA<CustomFoodHideLoading>(),
      isA<CustomFoodError>().having((event) => event.message, 'message', 'boom'),
    ],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'submit emits CustomFoodIncomplete when a required field is missing',
    build: CubitsFactories.buildCustomFoodCubit,
    act: (cubit) {
      cubit.nameChanged('Greek yogurt');
      return cubit.submit();
    },
    expectPresentation: () => [isA<CustomFoodIncomplete>()],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'submit emits a custom Food without uploading anything when there is no photo',
    build: CubitsFactories.buildCustomFoodCubit,
    act: (cubit) {
      fillEveryNutrient(cubit);
      cubit.brandChanged('Fage');
      return cubit.submit();
    },
    expectPresentation: () => [
      isA<CustomFoodReady>()
          .having((event) => event.food.name, 'food.name', 'Greek yogurt')
          .having((event) => event.food.brand, 'food.brand', 'Fage')
          .having((event) => event.food.source, 'food.source', FoodSource.custom)
          .having((event) => event.food.caloriesPer100g, 'food.caloriesPer100g', 10)
          .having((event) => event.food.imageUrl, 'food.imageUrl', isNull),
    ],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'submit leaves the brand null when it was left blank',
    build: CubitsFactories.buildCustomFoodCubit,
    act: (cubit) {
      fillEveryNutrient(cubit);
      cubit.brandChanged('   ');
      return cubit.submit();
    },
    expectPresentation: () => [isA<CustomFoodReady>().having((event) => event.food.brand, 'food.brand', isNull)],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'submit uploads the picked photo and carries its url into the Food',
    build: () {
      final imagePickerService = MockImagePickerService();
      final uploadFoodImageUseCase = MockUploadFoodImageUseCase();
      when(
        () => imagePickerService.pickImage(
          source: .gallery,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/food.png', bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'png'));
      when(
        () => uploadFoodImageUseCase(bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'png'),
      ).thenAnswer((_) async => const Success('https://example.com/food.png'));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService, uploadFoodImageUseCase: uploadFoodImageUseCase);
    },
    act: (cubit) async {
      fillEveryNutrient(cubit);
      await cubit.pickPhoto(source: .gallery);
      await cubit.submit();
    },
    expectPresentation: () => [
      isA<CustomFoodShowLoading>(),
      isA<CustomFoodHideLoading>(),
      isA<CustomFoodReady>().having((event) => event.food.imageUrl, 'food.imageUrl', 'https://example.com/food.png'),
    ],
  );

  blocPresentationTest<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
    'submit emits CustomFoodError and no Food when the photo upload fails',
    build: () {
      final imagePickerService = MockImagePickerService();
      final uploadFoodImageUseCase = MockUploadFoodImageUseCase();
      when(
        () => imagePickerService.pickImage(
          source: .gallery,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/food.png', bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'png'));
      when(
        () => uploadFoodImageUseCase(bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'png'),
      ).thenAnswer((_) async => const Failure(VTError(message: 'upload failed')));
      return CubitsFactories.buildCustomFoodCubit(imagePickerService: imagePickerService, uploadFoodImageUseCase: uploadFoodImageUseCase);
    },
    act: (cubit) async {
      fillEveryNutrient(cubit);
      await cubit.pickPhoto(source: .gallery);
      await cubit.submit();
    },
    expectPresentation: () => [
      isA<CustomFoodShowLoading>(),
      isA<CustomFoodHideLoading>(),
      isA<CustomFoodError>().having((event) => event.message, 'message', 'upload failed'),
    ],
  );
}

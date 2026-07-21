import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  test('returns the uploaded image URL from the repository', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildUploadFoodImageUseCase(dietRepository: dietRepository);
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(() => dietRepository.uploadFoodImage(bytes: bytes, fileExtension: 'jpg')).thenAnswer((_) async => const Success('https://example.com/food.jpg'));

    final uploadResult = await useCase(bytes: bytes, fileExtension: 'jpg');

    uploadResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, 'https://example.com/food.jpg'));
  });
}

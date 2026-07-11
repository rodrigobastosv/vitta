import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';

import '../../../../mocks/repositories_mocks.dart';

void main() {
  late MockDietRepository dietRepository;
  late DeleteFoodLogUseCase useCase;

  setUp(() {
    dietRepository = MockDietRepository();
    useCase = DeleteFoodLogUseCase(dietRepository: dietRepository);
  });

  test('delegates deletion to the repository', () async {
    when(() => dietRepository.deleteFoodLog(logId: 'log-1')).thenAnswer((_) async => const Success(null));

    final result = await useCase(logId: 'log-1');

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success():
        break;
    }
    verify(() => dietRepository.deleteFoodLog(logId: 'log-1')).called(1);
  });
}

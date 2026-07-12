import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates sign in to the repository', () async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.signIn(email: 'a@b.com', password: 'secret1')).thenAnswer(
      (_) async => const Success(AuthStatus(isAnonymous: false, email: 'a@b.com')),
    );
    final useCase = UseCasesFactories.buildSignInUseCase(authRepository: authRepository);

    final statusResult = await useCase(email: 'a@b.com', password: 'secret1');

    statusResult.when(
      (error) => fail('expected Success, got Failure($error)'),
      (value) => expect(value, const AuthStatus(isAnonymous: false, email: 'a@b.com')),
    );
  });
}

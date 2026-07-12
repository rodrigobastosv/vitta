import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates to the repository status getter', () {
    final authRepository = MockAuthRepository();
    when(() => authRepository.status).thenReturn(const AuthStatus(isAnonymous: true));
    final useCase = UseCasesFactories.buildGetAuthStatusUseCase(authRepository: authRepository);

    final status = useCase();

    expect(status, const AuthStatus(isAnonymous: true));
  });
}

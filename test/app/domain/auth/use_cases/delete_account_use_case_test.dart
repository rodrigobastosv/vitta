import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';
import '../../../../mocks/services_mocks.dart';

void main() {
  test('deletes the account then signs back in anonymously', () async {
    final authRepository = MockAuthRepository();
    final purchaseService = MockPurchaseService();
    when(authRepository.deleteAccount).thenAnswer((_) async => const Success(null));
    when(authRepository.signOut).thenAnswer((_) async => const Success(null));
    when(authRepository.signInAnonymously).thenAnswer((_) async => const Success(AnonymousUser()));
    when(purchaseService.logOut).thenAnswer((_) async {});
    final useCase = UseCasesFactories.buildDeleteAccountUseCase(
      authRepository: authRepository,
      purchaseService: purchaseService,
    );

    final statusResult = await useCase();

    statusResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, const AnonymousUser()));
    verify(authRepository.deleteAccount).called(1);
    verify(purchaseService.logOut).called(1);
    verify(authRepository.signInAnonymously).called(1);
  });

  test('does not sign out or re-sign-in when deletion fails', () async {
    final authRepository = MockAuthRepository();
    final purchaseService = MockPurchaseService();
    when(authRepository.deleteAccount).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final useCase = UseCasesFactories.buildDeleteAccountUseCase(
      authRepository: authRepository,
      purchaseService: purchaseService,
    );

    final statusResult = await useCase();

    statusResult.when((error) => expect(error.message, 'boom'), (value) => fail('expected Failure, got Success($value)'));
    verifyNever(purchaseService.logOut);
    verifyNever(authRepository.signOut);
    verifyNever(authRepository.signInAnonymously);
  });
}

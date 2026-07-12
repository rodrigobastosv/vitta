import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  test('loads the current auth status on construction', () {
    final getAuthStatusUseCase = MockGetAuthStatusUseCase();
    when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));

    final cubit = CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase);

    expect(cubit.state, const AuthLoaded(status: AuthStatus(isAnonymous: true)));
  });

  blocTest<AuthCubit, AuthState>(
    'refreshStatus re-reads the current auth status',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final cubit = CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase);
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: false, email: 'a@b.com'));
      return cubit;
    },
    act: (cubit) => cubit.refreshStatus(),
    expect: () => [const AuthLoaded(status: AuthStatus(isAnonymous: false, email: 'a@b.com'))],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signUp succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final signUpUseCase = MockSignUpUseCase();
      when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer(
        (_) async => const Success(AuthStatus(isAnonymous: false, email: 'a@b.com')),
      );
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthLoaded(status: AuthStatus(isAnonymous: false, email: 'a@b.com'))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'shows loading then hides it and signals sign-in when signUp succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final signUpUseCase = MockSignUpUseCase();
      when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer(
        (_) async => const Success(AuthStatus(isAnonymous: false, email: 'a@b.com')),
      );
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  test('signUp keeps the anonymous state when it fails', () async {
    final getAuthStatusUseCase = MockGetAuthStatusUseCase();
    when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
    final signUpUseCase = MockSignUpUseCase();
    when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signUpUseCase: signUpUseCase);

    await cubit.signUp(email: 'a@b.com', password: 'secret1');

    expect(cubit.state, const AuthLoaded(status: AuthStatus(isAnonymous: true)));
  });

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'emits AuthActionFailed when signUp fails',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final signUpUseCase = MockSignUpUseCase();
      when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthActionFailed>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signIn succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final signInUseCase = MockSignInUseCase();
      when(() => signInUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer(
        (_) async => const Success(AuthStatus(isAnonymous: false, email: 'a@b.com')),
      );
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signInUseCase: signInUseCase);
    },
    act: (cubit) => cubit.signIn(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthLoaded(status: AuthStatus(isAnonymous: false, email: 'a@b.com'))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'signals sign-in when signIn succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: true));
      final signInUseCase = MockSignInUseCase();
      when(() => signInUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer(
        (_) async => const Success(AuthStatus(isAnonymous: false, email: 'a@b.com')),
      );
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signInUseCase: signInUseCase);
    },
    act: (cubit) => cubit.signIn(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits a fresh anonymous status when signOut succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: false, email: 'a@b.com'));
      final signOutUseCase = MockSignOutUseCase();
      when(signOutUseCase.call).thenAnswer((_) async => const Success(AuthStatus(isAnonymous: true)));
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signOutUseCase: signOutUseCase);
    },
    act: (cubit) => cubit.signOut(),
    expect: () => [const AuthLoaded(status: AuthStatus(isAnonymous: true))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'does not signal sign-in when signOut succeeds',
    build: () {
      final getAuthStatusUseCase = MockGetAuthStatusUseCase();
      when(getAuthStatusUseCase.call).thenReturn(const AuthStatus(isAnonymous: false, email: 'a@b.com'));
      final signOutUseCase = MockSignOutUseCase();
      when(signOutUseCase.call).thenAnswer((_) async => const Success(AuthStatus(isAnonymous: true)));
      return CubitsFactories.buildAuthCubit(getAuthStatusUseCase: getAuthStatusUseCase, signOutUseCase: signOutUseCase);
    },
    act: (cubit) => cubit.signOut(),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>()],
  );
}

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  test('loads the current auth status on construction, defaulting to sign-up mode', () {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());

    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);

    expect(cubit.state, const AuthState(user: AnonymousUser()));
    expect(cubit.state.isSignUpMode, isTrue);
  });

  blocTest<AuthCubit, AuthState>(
    'refreshUser re-reads the current user',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(email: 'a@b.com'));
      return cubit;
    },
    act: (cubit) => cubit.refreshUser(),
    expect: () => [const AuthState(user: AuthenticatedUser(email: 'a@b.com'))],
  );

  blocTest<AuthCubit, AuthState>(
    'setSignUpMode toggles the mode without touching the status',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);
    },
    act: (cubit) => cubit.setSignUpMode(isSignUp: false),
    expect: () => [const AuthState(user: AnonymousUser(), isSignUpMode: false)],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signUp succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signUpUseCase = MockSignUpUseCase();
      when(
        () => signUpUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.submit(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthState(user: AuthenticatedUser(email: 'a@b.com'))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'shows loading then hides it and signals sign-in when signUp succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signUpUseCase = MockSignUpUseCase();
      when(
        () => signUpUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.submit(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  test('signUp keeps the anonymous state when it fails', () async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final signUpUseCase = MockSignUpUseCase();
    when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);

    await cubit.submit(email: 'a@b.com', password: 'secret1');

    expect(cubit.state, const AuthState(user: AnonymousUser()));
  });

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'emits AuthActionFailed when signUp fails',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signUpUseCase = MockSignUpUseCase();
      when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.submit(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthActionFailed>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signIn succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signInUseCase = MockSignInUseCase();
      when(
        () => signInUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signInUseCase: signInUseCase)..setSignUpMode(isSignUp: false);
    },
    act: (cubit) => cubit.submit(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthState(user: AuthenticatedUser(email: 'a@b.com'), isSignUpMode: false)],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'signals sign-in when signIn succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signInUseCase = MockSignInUseCase();
      when(
        () => signInUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signInUseCase: signInUseCase)..setSignUpMode(isSignUp: false);
    },
    act: (cubit) => cubit.submit(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits a fresh anonymous status when signOut succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(email: 'a@b.com'));
      final signOutUseCase = MockSignOutUseCase();
      when(signOutUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signOutUseCase: signOutUseCase);
    },
    act: (cubit) => cubit.signOut(),
    expect: () => [const AuthState(user: AnonymousUser())],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'does not signal sign-in when signOut succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(email: 'a@b.com'));
      final signOutUseCase = MockSignOutUseCase();
      when(signOutUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signOutUseCase: signOutUseCase);
    },
    act: (cubit) => cubit.signOut(),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>()],
  );
}

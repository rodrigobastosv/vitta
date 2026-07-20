import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ImagePickerSource.gallery);
    registerFallbackValue(Uint8List(0));
  });

  test('logs a sign_in user action when signIn succeeds', () async {
    final loggingService = useMockLog();
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final signInUseCase = MockSignInUseCase();
    when(
      () => signInUseCase(email: 'a@b.com', password: 'secret1'),
    ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signInUseCase: signInUseCase);

    await cubit.signIn(email: 'a@b.com', password: 'secret1');

    verify(() => loggingService.logAction('sign_in')).called(1);
  });

  test('logs a sign_out user action when signOut succeeds', () async {
    final loggingService = useMockLog();
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
    final signOutUseCase = MockSignOutUseCase();
    when(signOutUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signOutUseCase: signOutUseCase);

    await cubit.signOut();

    verify(() => loggingService.logAction('sign_out')).called(1);
  });

  test('loads the current auth status on construction', () {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());

    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);

    expect(cubit.state, const AuthState(user: AnonymousUser()));
  });

  blocTest<AuthCubit, AuthState>(
    'refreshUser re-reads the current user',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      return cubit;
    },
    act: (cubit) => cubit.refreshUser(),
    expect: () => [const AuthState(user: AuthenticatedUser(id: 'user-1', email: 'a@b.com'))],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signUp succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signUpUseCase = MockSignUpUseCase();
      when(
        () => signUpUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthState(user: AuthenticatedUser(id: 'user-1', email: 'a@b.com'))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'shows loading then hides it and signals sign-in when signUp succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signUpUseCase = MockSignUpUseCase();
      when(
        () => signUpUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);
    },
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  test('signUp keeps the anonymous state when it fails', () async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final signUpUseCase = MockSignUpUseCase();
    when(() => signUpUseCase(email: 'a@b.com', password: 'secret1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase);

    await cubit.signUp(email: 'a@b.com', password: 'secret1');

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
    act: (cubit) => cubit.signUp(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthActionFailed>()],
  );

  test('signUp passes a chosen preset avatar through and no photo url', () async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final signUpUseCase = MockSignUpUseCase();
    when(
      () => signUpUseCase(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
        avatarId: any(named: 'avatarId'),
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signUpUseCase: signUpUseCase)
      ..setAvatarPreset('man-light');

    await cubit.signUp(email: 'a@b.com', password: 'secret1', displayName: 'Rod');

    verify(() => signUpUseCase(email: 'a@b.com', password: 'secret1', displayName: 'Rod', avatarId: 'man-light')).called(1);
  });

  test('signUp uploads a picked photo and passes its url with no preset', () async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final imagePickerService = MockImagePickerService();
    when(
      () => imagePickerService.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
      ),
    ).thenAnswer((_) async => PickedImage(path: 'p.jpg', bytes: Uint8List.fromList([1, 2, 3]), fileExtension: 'jpg'));
    final uploadAvatarUseCase = MockUploadAvatarUseCase();
    when(
      () => uploadAvatarUseCase(
        bytes: any(named: 'bytes'),
        fileExtension: any(named: 'fileExtension'),
      ),
    ).thenAnswer((_) async => const Success('https://cdn/a.jpg'));
    final signUpUseCase = MockSignUpUseCase();
    when(
      () => signUpUseCase(
        email: any(named: 'email'),
        password: any(named: 'password'),
        displayName: any(named: 'displayName'),
        avatarId: any(named: 'avatarId'),
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
    final cubit = CubitsFactories.buildAuthCubit(
      getUserUseCase: getUserUseCase,
      imagePickerService: imagePickerService,
      uploadAvatarUseCase: uploadAvatarUseCase,
      signUpUseCase: signUpUseCase,
    );

    await cubit.pickAvatarPhoto(ImagePickerSource.gallery);
    await cubit.signUp(email: 'a@b.com', password: 'secret1');

    verify(() => signUpUseCase(email: 'a@b.com', password: 'secret1', avatarUrl: 'https://cdn/a.jpg')).called(1);
  });

  test('picking a photo clears a previously chosen preset, and vice versa', () async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AnonymousUser());
    final imagePickerService = MockImagePickerService();
    when(
      () => imagePickerService.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
      ),
    ).thenAnswer((_) async => PickedImage(path: 'p.jpg', bytes: Uint8List.fromList([9]), fileExtension: 'jpg'));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, imagePickerService: imagePickerService);

    cubit.setAvatarPreset('man-light');
    await cubit.pickAvatarPhoto(ImagePickerSource.gallery);
    expect(cubit.state.draftAvatarId, isNull);
    expect(cubit.state.draftAvatarBytes, isNotNull);

    cubit.setAvatarPreset('woman-light');
    expect(cubit.state.draftAvatarBytes, isNull);
    expect(cubit.state.draftAvatarId, 'woman-light');
  });

  test('updateProfile emits the new user and logs profile_updated', () async {
    final loggingService = useMockLog();
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
    final updateProfileUseCase = MockUpdateProfileUseCase();
    when(
      () => updateProfileUseCase(
        displayName: any(named: 'displayName'),
        avatarId: any(named: 'avatarId'),
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com', displayName: 'Rod', avatarId: 'man-light')));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, updateProfileUseCase: updateProfileUseCase)
      ..setAvatarPreset('man-light');

    await cubit.updateProfile(displayName: 'Rod');

    expect(cubit.state.user, const AuthenticatedUser(id: 'user-1', email: 'a@b.com', displayName: 'Rod', avatarId: 'man-light'));
    verify(() => loggingService.logAction('profile_updated')).called(1);
  });

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'updateProfile signals AuthProfileUpdated on success',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      final updateProfileUseCase = MockUpdateProfileUseCase();
      when(
        () => updateProfileUseCase(
          displayName: any(named: 'displayName'),
          avatarId: any(named: 'avatarId'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, updateProfileUseCase: updateProfileUseCase);
    },
    act: (cubit) => cubit.updateProfile(displayName: 'Rod'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthProfileUpdated>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits the new status when signIn succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signInUseCase = MockSignInUseCase();
      when(
        () => signInUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signInUseCase: signInUseCase);
    },
    act: (cubit) => cubit.signIn(email: 'a@b.com', password: 'secret1'),
    expect: () => [const AuthState(user: AuthenticatedUser(id: 'user-1', email: 'a@b.com'))],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'signals sign-in when signIn succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AnonymousUser());
      final signInUseCase = MockSignInUseCase();
      when(
        () => signInUseCase(email: 'a@b.com', password: 'secret1'),
      ).thenAnswer((_) async => const Success(AuthenticatedUser(id: 'user-1', email: 'a@b.com')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signInUseCase: signInUseCase);
    },
    act: (cubit) => cubit.signIn(email: 'a@b.com', password: 'secret1'),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthSignedIn>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits a fresh anonymous status when signOut succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
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
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      final signOutUseCase = MockSignOutUseCase();
      when(signOutUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, signOutUseCase: signOutUseCase);
    },
    act: (cubit) => cubit.signOut(),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>()],
  );

  test('logs an account_deleted user action when deleteAccount succeeds', () async {
    final loggingService = useMockLog();
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
    final deleteAccountUseCase = MockDeleteAccountUseCase();
    when(deleteAccountUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, deleteAccountUseCase: deleteAccountUseCase);

    await cubit.deleteAccount();

    verify(() => loggingService.logAction('account_deleted')).called(1);
  });

  blocTest<AuthCubit, AuthState>(
    'emits a fresh anonymous status when deleteAccount succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      final deleteAccountUseCase = MockDeleteAccountUseCase();
      when(deleteAccountUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, deleteAccountUseCase: deleteAccountUseCase);
    },
    act: (cubit) => cubit.deleteAccount(),
    expect: () => [const AuthState(user: AnonymousUser())],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'shows loading then signals AuthAccountDeleted when deleteAccount succeeds',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      final deleteAccountUseCase = MockDeleteAccountUseCase();
      when(deleteAccountUseCase.call).thenAnswer((_) async => const Success(AnonymousUser()));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, deleteAccountUseCase: deleteAccountUseCase);
    },
    act: (cubit) => cubit.deleteAccount(),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthAccountDeleted>()],
  );

  blocPresentationTest<AuthCubit, AuthState, AuthPresentationEvent>(
    'emits AuthActionFailed and no deletion signal when deleteAccount fails',
    build: () {
      final getUserUseCase = MockGetUserUseCase();
      when(getUserUseCase.call).thenReturn(const AuthenticatedUser(id: 'user-1', email: 'a@b.com'));
      final deleteAccountUseCase = MockDeleteAccountUseCase();
      when(deleteAccountUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase, deleteAccountUseCase: deleteAccountUseCase);
    },
    act: (cubit) => cubit.deleteAccount(),
    expectPresentation: () => [isA<AuthShowLoading>(), isA<AuthHideLoading>(), isA<AuthActionFailed>()],
  );
}

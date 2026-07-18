import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionResponse;
import 'package:vitta/app/core/services/supabase/supabase_function.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

import '../../../../mocks/services_mocks.dart';

void main() {
  test('status maps the auth user metadata into the profile fields', () {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(false);
    when(() => supabaseService.currentUserEmail).thenReturn('a@b.com');
    when(() => supabaseService.currentUserMetadata).thenReturn({'display_name': 'Rod', 'avatar_id': 'man-light', 'avatar_url': null});
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    expect(dataSource.status, const AuthenticatedUser(email: 'a@b.com', displayName: 'Rod', avatarId: 'man-light'));
  });

  test('status leaves the profile fields null when there is no metadata', () {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(false);
    when(() => supabaseService.currentUserEmail).thenReturn('a@b.com');
    when(() => supabaseService.currentUserMetadata).thenReturn(null);
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    expect(dataSource.status, const AuthenticatedUser(email: 'a@b.com'));
  });

  test('status is an anonymous user when the session is anonymous', () {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(true);
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    expect(dataSource.status, const AnonymousUser());
  });

  test('deleteAccount invokes the delete-account function and succeeds', () async {
    final supabaseService = MockSupabaseService();
    when(
      () => supabaseService.invoke(SupabaseFunction.deleteAccount, body: const {}),
    ).thenAnswer((_) async => const FunctionResponse(status: 200));
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    final deletedResult = await dataSource.deleteAccount();

    deletedResult.when((error) => fail('expected Success, got Failure($error)'), (_) {});
    verify(() => supabaseService.invoke(SupabaseFunction.deleteAccount, body: const {})).called(1);
  });

  test('deleteAccount returns a Failure when the function call throws', () async {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.invoke(SupabaseFunction.deleteAccount, body: const {})).thenThrow(Exception('boom'));
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    final deletedResult = await dataSource.deleteAccount();

    deletedResult.when((error) => expect(error.message, 'Failed to delete account'), (_) => fail('expected Failure'));
  });
}

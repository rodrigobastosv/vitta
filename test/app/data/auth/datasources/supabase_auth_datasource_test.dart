import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

import '../../../../mocks/services_mocks.dart';

void main() {
  test('status maps the auth user metadata into the profile fields', () {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(false);
    when(() => supabaseService.currentUserEmail).thenReturn('a@b.com');
    when(() => supabaseService.currentUserMetadata).thenReturn({'display_name': 'Rod', 'avatar_id': 'leaf', 'avatar_url': null});
    final dataSource = SupabaseAuthDataSource(supabaseService: supabaseService);

    expect(dataSource.status, const AuthenticatedUser(email: 'a@b.com', displayName: 'Rod', avatarId: 'leaf'));
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
}

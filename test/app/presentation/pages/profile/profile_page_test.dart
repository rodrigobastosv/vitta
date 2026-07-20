import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/profile/profile_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../fixtures/premium_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  Future<void> pumpProfile(WidgetTester tester, {required User user}) async {
    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(user);
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);
    G.registerFactory<AuthCubit>(() => cubit);
    addTearDown(() => G.unregister<AuthCubit>());

    await tester.pumpWidget(
      withTestPremium(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfilePage(),
        ),
      ),
    );
  }

  testWidgets('shows a guest header with the sign in action when anonymous', (tester) async {
    await pumpProfile(tester, user: const AnonymousUser());

    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Sign in or create account'), findsOneWidget);
    expect(find.text('Log out'), findsNothing);
    expect(find.text('Macro goals'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('does not offer delete account to an anonymous user', (tester) async {
    await pumpProfile(tester, user: const AnonymousUser());

    expect(find.text('Delete account'), findsNothing);
  });

  testWidgets('shows the email and a log out action when signed in', (tester) async {
    await pumpProfile(tester, user: const AuthenticatedUser(id: 'user-1', email: 'anna@example.com'));

    expect(find.text('anna@example.com'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Sign in or create account'), findsNothing);
  });

  testWidgets('offers delete account to a signed-in user and confirms irreversibility', (tester) async {
    await pumpProfile(tester, user: const AuthenticatedUser(id: 'user-1', email: 'anna@example.com'));

    expect(find.text('Delete account'), findsOneWidget);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.textContaining("can't be undone"), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

const _greetings = ['Good morning', 'Good afternoon', 'Good evening'];

void main() {
  Future<void> pumpHome(WidgetTester tester, {required User user, Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final getUserUseCase = MockGetUserUseCase();
    when(getUserUseCase.call).thenReturn(user);
    final cubit = CubitsFactories.buildAuthCubit(getUserUseCase: getUserUseCase);
    G.registerFactory<AuthCubit>(() => cubit);
    addTearDown(() => G.unregister<AuthCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder greetingFinder() => find.byWidgetPredicate((widget) => widget is Text && _greetings.contains(widget.data));

  testWidgets('greets a signed-in user by name instead of the app title', (tester) async {
    await pumpHome(tester, user: const AuthenticatedUser(email: 'rodrigo@example.com', displayName: 'Rodrigo'));

    expect(greetingFinder(), findsOneWidget);
    expect(find.text('Rodrigo'), findsOneWidget);
    expect(find.text('Vitta'), findsNothing);
  });

  testWidgets('keeps the app title for an anonymous user with no name', (tester) async {
    await pumpHome(tester, user: const AnonymousUser());

    expect(find.text('Vitta'), findsOneWidget);
    expect(greetingFinder(), findsNothing);
  });

  for (final size in const [Size(320, 568), Size(360, 640), Size(390, 844)]) {
    testWidgets('does not overflow at ${size.width.toInt()}x${size.height.toInt()} for a signed-in user', (tester) async {
      await pumpHome(
        tester,
        user: const AuthenticatedUser(email: 'rodrigo@example.com', displayName: 'Rodrigo'),
        size: size,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at ${size.width.toInt()}x${size.height.toInt()} for an anonymous user', (tester) async {
      await pumpHome(tester, user: const AnonymousUser(), size: size);
      expect(tester.takeException(), isNull);
    });
  }
}

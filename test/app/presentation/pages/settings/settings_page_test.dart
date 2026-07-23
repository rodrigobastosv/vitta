import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/settings/settings_page.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_navigation_tile.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(const AppSettings()));

  AppCubit buildAppCubit([AppSettings settings = const AppSettings()]) {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(settings);
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
    return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
  }

  Future<void> pumpSettings(WidgetTester tester, AppCubit appCubit, {Locale? locale}) => tester.pumpWidget(
    BlocProvider<AppCubit>.value(
      value: appCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const SettingsPage(),
      ),
    ),
  );

  testWidgets('states every preference value without scrolling', (tester) async {
    await pumpSettings(tester, buildAppCubit());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SettingsNavigationTile), findsNWidgets(5));
    expect(find.text('Home screen'), findsOneWidget);
    expect(find.text('Logging reminders'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Unit system'), findsOneWidget);

    expect(find.text('System default'), findsNWidgets(2));
    expect(find.text('Metric (g/kg)'), findsOneWidget);
    expect(find.byType(SettingsOptionTile), findsNothing);
  });

  testWidgets('the stated value follows the setting', (tester) async {
    await pumpSettings(tester, buildAppCubit(const AppSettings(locale: Locale('pt'), themeMode: ThemeMode.dark, unitSystem: UnitSystem.imperial)));

    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Imperial (oz/lb)'), findsOneWidget);
  });

  testWidgets('picking from the theme sheet changes the theme', (tester) async {
    final appCubit = buildAppCubit();
    await pumpSettings(tester, appCubit);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionTile), findsNWidgets(3));

    await tester.tap(find.widgetWithText(SettingsOptionTile, 'Dark'));
    await tester.pumpAndSettle();

    expect(appCubit.state.themeMode, ThemeMode.dark);
    expect(find.byType(SettingsOptionTile), findsNothing);
  });

  testWidgets('dismissing the language sheet leaves the locale alone', (tester) async {
    final appCubit = buildAppCubit(const AppSettings(locale: Locale('en')));
    await pumpSettings(tester, appCubit);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 60));
    await tester.pumpAndSettle();

    expect(appCubit.state.locale, const Locale('en'));
  });

  testWidgets('picking system default clears the locale override', (tester) async {
    final appCubit = buildAppCubit(const AppSettings(locale: Locale('en')));
    await pumpSettings(tester, appCubit);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SettingsOptionTile, 'System default'));
    await tester.pumpAndSettle();

    expect(appCubit.state.locale, isNull);
  });

  testWidgets('a selected option announces itself as selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSettings(tester, buildAppCubit(const AppSettings(themeMode: ThemeMode.dark)));

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.widgetWithText(SettingsOptionTile, 'Dark')),
      matchesSemantics(
        label: 'Dark',
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.widgetWithText(SettingsOptionTile, 'Light')),
      matchesSemantics(
        label: 'Light',
        hasSelectedState: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    semantics.dispose();
  });

  for (final locale in const [Locale('en'), Locale('pt')]) {
    testWidgets('does not overflow at 320px in ${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpSettings(tester, buildAppCubit(const AppSettings(unitSystem: UnitSystem.imperial)), locale: locale);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('does not close the shared AppCubit when it leaves the tree', (tester) async {
    final appCubit = buildAppCubit();
    await pumpSettings(tester, appCubit);

    await tester.pumpWidget(const SizedBox());

    expect(appCubit.isClosed, isFalse);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/settings/settings_page.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(const AppSettings()));

  AppCubit buildAppCubit() {
    final getAppSettingsUseCase = MockGetAppSettingsUseCase();
    final saveAppSettingsUseCase = MockSaveAppSettingsUseCase();
    when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
    when(() => saveAppSettingsUseCase(any())).thenAnswer((_) async {});
    return CubitsFactories.buildAppCubit(getAppSettingsUseCase: getAppSettingsUseCase, saveAppSettingsUseCase: saveAppSettingsUseCase);
  }

  Future<void> pumpSettings(WidgetTester tester, AppCubit appCubit) => tester.pumpWidget(
    BlocProvider<AppCubit>.value(
      value: appCubit,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(),
      ),
    ),
  );

  testWidgets('renders the language, theme and unit options', (tester) async {
    await pumpSettings(tester, buildAppCubit());

    expect(find.text('Settings'), findsOneWidget);
    // 3 language + 3 theme + 2 unit-system options.
    expect(find.byType(SettingsOptionTile), findsNWidgets(8));
  });

  testWidgets('marks the active option and switches on tap', (tester) async {
    final appCubit = buildAppCubit();
    await pumpSettings(tester, appCubit);

    final darkTile = tester.widget<SettingsOptionTile>(find.widgetWithText(SettingsOptionTile, 'Dark'));
    expect(darkTile.isSelected, isFalse);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(appCubit.state.themeMode, ThemeMode.dark);
  });

  testWidgets('does not close the shared AppCubit when it leaves the tree', (tester) async {
    final appCubit = buildAppCubit();
    await pumpSettings(tester, appCubit);

    await tester.pumpWidget(const SizedBox());

    expect(appCubit.isClosed, isFalse);
  });
}

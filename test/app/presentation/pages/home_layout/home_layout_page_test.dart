import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_cubit.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_page.dart';
import 'package:vitta/app/presentation/pages/home_layout/widgets/home_layout_feature_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(HomeLayout.shipped));

  Future<HomeLayoutCubit> pumpHomeLayout(WidgetTester tester, {HomeLayout layout = HomeLayout.shipped}) async {
    final getHomeLayoutUseCase = MockGetHomeLayoutUseCase();
    when(getHomeLayoutUseCase.call).thenReturn(layout);
    final saveHomeLayoutUseCase = MockSaveHomeLayoutUseCase();
    when(() => saveHomeLayoutUseCase(layout: any(named: 'layout'))).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildHomeLayoutCubit(getHomeLayoutUseCase: getHomeLayoutUseCase, saveHomeLayoutUseCase: saveHomeLayoutUseCase);

    if (G.isRegistered<HomeLayoutCubit>()) {
      G.unregister<HomeLayoutCubit>();
    }
    G.registerFactory<HomeLayoutCubit>(() => cubit);
    addTearDown(() => G.unregister<HomeLayoutCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeLayoutPage(),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('every feature exposes a drag handle, so the list reads as reorderable', (tester) async {
    await pumpHomeLayout(tester);

    expect(find.byType(HomeLayoutFeatureTile), findsNWidgets(HomeFeature.values.length));
    expect(find.byType(VTDragHandle), findsNWidgets(HomeFeature.values.length));
  });

  testWidgets('dragging a feature by its handle reorders the layout', (tester) async {
    final cubit = await pumpHomeLayout(tester);

    final tileHeight = tester.getSize(find.byType(HomeLayoutFeatureTile).first).height;
    final gesture = await tester.startGesture(tester.getCenter(find.byType(VTDragHandle).first));
    await tester.pump(kLongPressTimeout);
    for (var moved = 0.0; moved < tileHeight + 1; moved += 10) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(cubit.state.layout.order.take(2), [HomeFeature.water, HomeFeature.diet]);
  });

  testWidgets('the shipped layout is what an untouched setting shows', (tester) async {
    final cubit = await pumpHomeLayout(tester);

    expect(cubit.state.layout, HomeLayout.shipped);
    expect(find.text('Headline'), findsOneWidget);
    expect(find.text('Supporting row'), findsNWidgets(3));
    expect(find.text('Tile'), findsNWidgets(2));
  });
}

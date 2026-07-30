import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/workout_region_volume.dart';
import 'package:vitta/app/presentation/general/workout_body_map_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> pumpCard(WidgetTester tester, {required WorkoutRegionVolume regionVolume, Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: WorkoutBodyMapCard(regionVolume: regionVolume)),
    ),
  );
  await tester.pumpAndSettle();
}

const _chestAndLegs = WorkoutRegionVolume(
  volumeByRegion: {BodyRegion.chest: 1200, BodyRegion.legs: 400},
  setsByRegion: {BodyRegion.chest: 4, BodyRegion.legs: 1},
);

bool _isShadeOf(Color painted, Color accent) => painted.toARGB32() & 0x00FFFFFF == accent.toARGB32() & 0x00FFFFFF;

PaintPattern paintsShadeOf(Color accent) =>
    paints..something((symbol, arguments) => symbol == #drawPath && _isShadeOf((arguments[1] as Paint).color, accent));

void main() {
  testWidgets('shows both views and names every region that was worked', (tester) async {
    await pumpCard(tester, regionVolume: _chestAndLegs);

    expect(find.byType(VTBodyMap), findsNWidgets(2));
    expect(find.text('Front view'), findsOneWidget);
    expect(find.text('Rear view'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
  });

  testWidgets('a region nothing was logged for is neither named nor tinted', (tester) async {
    await pumpCard(tester, regionVolume: _chestAndLegs);

    expect(find.text('Back'), findsNothing);
    expect(find.byType(VTBodyMap).first, isNot(paintsShadeOf(VTColors.bodyRegionBack)));
    expect(find.byType(VTBodyMap).last, isNot(paintsShadeOf(VTColors.bodyRegionBack)));
  });

  testWidgets('tints the front figure with the regions it can show', (tester) async {
    await pumpCard(tester, regionVolume: _chestAndLegs);

    expect(find.byType(VTBodyMap).first, paintsShadeOf(VTColors.bodyRegionChest));
    expect(find.byType(VTBodyMap).first, paintsShadeOf(VTColors.bodyRegionLegs));
  });

  for (final locale in [const Locale('en'), const Locale('pt')]) {
    testWidgets('fits a 320px screen in ${locale.languageCode}', (tester) async {
      await pumpCard(
        tester,
        locale: locale,
        regionVolume: const WorkoutRegionVolume(
          volumeByRegion: {
            BodyRegion.chest: 1200,
            BodyRegion.back: 900,
            BodyRegion.shoulders: 300,
            BodyRegion.arms: 200,
            BodyRegion.core: 100,
            BodyRegion.legs: 800,
          },
          setsByRegion: {
            BodyRegion.chest: 4,
            BodyRegion.back: 3,
            BodyRegion.shoulders: 2,
            BodyRegion.arms: 2,
            BodyRegion.core: 1,
            BodyRegion.legs: 3,
          },
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_geometry.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

Future<void> pumpBodyMap(
  WidgetTester tester, {
  VTBodyMapView view = VTBodyMapView.front,
  List<VTBodyMapHighlight> highlights = const [],
  String? semanticLabel,
}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(
      body: Center(child: VTBodyMap(view: view, highlights: highlights, semanticLabel: semanticLabel)),
    ),
  ),
);

bool _isShadeOf(Color painted, Color accent) => painted.toARGB32() & 0x00FFFFFF == accent.toARGB32() & 0x00FFFFFF;

PaintPattern paintsShadeOf(Color accent) =>
    paints..something((symbol, arguments) => symbol == #drawPath && _isShadeOf((arguments[1] as Paint).color, accent));

double paintedAlphaOf(WidgetTester tester, Color accent) {
  final alphas = <double>[];
  expect(
    find.byType(VTBodyMap),
    paints..something((symbol, arguments) {
      if (symbol != #drawPath) {
        return false;
      }
      final painted = (arguments[1] as Paint).color;
      if (!_isShadeOf(painted, accent)) {
        return false;
      }
      alphas.add(painted.a);
      return true;
    }),
  );
  return alphas.first;
}

int strokedPathCount(WidgetTester tester) {
  var stroked = 0;
  expect(
    find.byType(VTBodyMap),
    paints..everything((symbol, arguments) {
      if (symbol == #drawPath && (arguments[1] as Paint).style == PaintingStyle.stroke) {
        stroked++;
      }
      return true;
    }),
  );
  return stroked;
}

void main() {
  testWidgets('paints a worked muscle in its accent and leaves an unworked one untinted', (tester) async {
    await pumpBodyMap(tester, highlights: const [VTBodyMapHighlight(part: .chest, color: VTColors.bodyRegionChest, intensity: 1)]);

    expect(find.byType(VTBodyMap), paintsShadeOf(VTColors.bodyRegionChest));
    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionLegs)));
  });

  testWidgets('a body with nothing worked paints no accent at all', (tester) async {
    await pumpBodyMap(tester);

    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionChest)));
    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionBack)));
  });

  testWidgets('outlines every muscle the view can show, worked or not', (tester) async {
    await pumpBodyMap(tester);
    final drawnUnworked = strokedPathCount(tester);

    final showable = [
      for (final part in VTBodyPart.values) ...VTBodyMapGeometry.partsOf(part, .front, VTBodyFigure.male),
    ];

    expect(showable, isNotEmpty);
    expect(drawnUnworked, showable.length + 1);
  });

  testWidgets('a harder-worked muscle paints more opaquely than a lighter one', (tester) async {
    await pumpBodyMap(
      tester,
      highlights: const [VTBodyMapHighlight(part: .quadriceps, color: VTColors.bodyRegionLegs, intensity: 1)],
    );
    final hardest = paintedAlphaOf(tester, VTColors.bodyRegionLegs);

    await pumpBodyMap(
      tester,
      highlights: const [VTBodyMapHighlight(part: .quadriceps, color: VTColors.bodyRegionLegs, intensity: 0.2)],
    );

    expect(paintedAlphaOf(tester, VTColors.bodyRegionLegs), lessThan(hardest));
  });

  testWidgets('a muscle the view cannot show is not painted on it', (tester) async {
    const chest = [VTBodyMapHighlight(part: .chest, color: VTColors.bodyRegionChest, intensity: 1)];

    await pumpBodyMap(tester, highlights: chest);
    expect(find.byType(VTBodyMap), paintsShadeOf(VTColors.bodyRegionChest));

    await pumpBodyMap(tester, view: .back, highlights: chest);
    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionChest)));
  });

  testWidgets('the back view paints the upper back the front cannot show', (tester) async {
    const lats = [VTBodyMapHighlight(part: .upperBack, color: VTColors.bodyRegionBack, intensity: 1)];

    await pumpBodyMap(tester, view: .back, highlights: lats);
    expect(find.byType(VTBodyMap), paintsShadeOf(VTColors.bodyRegionBack));

    await pumpBodyMap(tester, highlights: lats);
    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionBack)));
  });

  testWidgets('tells the biceps and the triceps apart by view', (tester) async {
    const biceps = [VTBodyMapHighlight(part: .biceps, color: VTColors.bodyRegionArms, intensity: 1)];

    await pumpBodyMap(tester, highlights: biceps);
    expect(find.byType(VTBodyMap), paintsShadeOf(VTColors.bodyRegionArms));

    await pumpBodyMap(tester, view: .back, highlights: biceps);
    expect(find.byType(VTBodyMap), isNot(paintsShadeOf(VTColors.bodyRegionArms)));
  });

  testWidgets('exposes an accessibility label when given one', (tester) async {
    await pumpBodyMap(tester, semanticLabel: 'Chest, arms and legs worked');

    expect(find.bySemanticsLabel('Chest, arms and legs worked'), findsOneWidget);
  });

  testWidgets('stays silent when no label is given', (tester) async {
    await pumpBodyMap(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}

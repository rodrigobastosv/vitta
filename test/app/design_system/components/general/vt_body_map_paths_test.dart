import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_geometry.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_paths.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';

void main() {
  test('every figure and view carries an outline and most of the muscles', () {
    for (final figure in VTBodyFigure.values) {
      for (final view in VTBodyMapView.values) {
        expect(VTBodyMapPaths.outline[figure]?[view], isNotNull, reason: 'no outline for $figure $view');
        final drawn = VTBodyPart.values.where((part) => VTBodyMapGeometry.partsOf(part, view, figure).isNotEmpty);
        expect(drawn.length, greaterThanOrEqualTo(8), reason: 'only ${drawn.length} muscles for $figure $view');
      }
    }
  });

  test('the two figures are genuinely different artwork', () {
    for (final view in VTBodyMapView.values) {
      expect(VTBodyMapPaths.outline[VTBodyFigure.male]![view], isNot(VTBodyMapPaths.outline[VTBodyFigure.female]![view]));
    }
  });

  test('a muscle only ever resolves to the figure and view it was asked for', () {
    final maleChest = VTBodyMapGeometry.partsOf(VTBodyPart.chest, .front, VTBodyFigure.male);
    final femaleChest = VTBodyMapGeometry.partsOf(VTBodyPart.chest, .front, VTBodyFigure.female);

    expect(maleChest, isNotEmpty);
    expect(femaleChest, isNotEmpty);
    expect(maleChest.first.getBounds(), isNot(femaleChest.first.getBounds()));
    expect(VTBodyMapGeometry.partsOf(VTBodyPart.chest, .back, VTBodyFigure.male), isEmpty);
  });

  test('the back figure is translated onto the same origin as the front one', () {
    final back = VTBodyMapGeometry.body(VTBodyFigure.male, .back);

    expect(back.getBounds().left, lessThan(VTBodyMapPaths.designSize.width));
  });
}

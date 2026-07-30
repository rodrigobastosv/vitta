import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_paths.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';

// Parsing 100KB of vendored path data on every paint would be visible, and the
// data is immutable, so every parse is memoized for the life of the process.
abstract class VTBodyMapGeometry {
  static const Size designSize = VTBodyMapPaths.designSize;

  static final Map<(VTBodyFigure, VTBodyMapView), Path> _bodies = {};
  static final Map<(VTBodyFigure, VTBodyMapView, VTBodyPart), List<Path>> _parts = {};

  static Path body(VTBodyFigure figure, VTBodyMapView view) =>
      _bodies[(figure, view)] ??= _parse(VTBodyMapPaths.outline[figure]![view]!, view);

  static List<Path> partsOf(VTBodyPart part, VTBodyMapView view, VTBodyFigure figure) =>
      _parts[(figure, view, part)] ??= [
        for (final path in VTBodyMapPaths.parts[figure]![view]![part] ?? const <String>[]) _parse(path, view),
      ];

  // The back figure is authored to the right of the front one in one shared
  // canvas, so its coordinates carry the whole viewBox width as an x offset.
  static Path _parse(String data, VTBodyMapView view) => parseSvgPathData(
    data,
  ).transform((Matrix4.identity()..translateByDouble(-VTBodyMapPaths.viewOriginX[view]!, 0, 0, 1)).storage);
}

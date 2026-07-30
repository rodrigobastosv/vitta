import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_geometry.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';

class VTBodyMap extends StatelessWidget {
  const VTBodyMap({
    required this.view,
    required this.highlights,
    this.figure = VTBodyFigure.male,
    this.height = 168,
    this.semanticLabel,
    super.key,
  });

  static const double minHighlightAlpha = 0.35;
  static const double maxHighlightAlpha = 0.95;

  final VTBodyMapView view;
  final List<VTBodyMapHighlight> highlights;
  final VTBodyFigure figure;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return VTSemanticSummary(
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: AspectRatio(
          aspectRatio: VTBodyMapGeometry.designSize.aspectRatio,
          child: CustomPaint(
            painter: _BodyMapPainter(
              view: view,
              figure: figure,
              highlights: highlights,
              bodyColor: colorScheme.onSurface.withValues(alpha: 0.10),
              outlineColor: colorScheme.onSurface.withValues(alpha: 0.22),
              definitionColor: colorScheme.onSurface.withValues(alpha: 0.16),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.view,
    required this.figure,
    required this.highlights,
    required this.bodyColor,
    required this.outlineColor,
    required this.definitionColor,
  });

  final VTBodyMapView view;
  final List<VTBodyMapHighlight> highlights;
  final VTBodyFigure figure;
  final Color bodyColor;
  final Color outlineColor;
  final Color definitionColor;

  static const double _outlineWidth = 1.2;
  static const double _definitionWidth = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    const design = VTBodyMapGeometry.designSize;
    final scale = math.min(size.width / design.width, size.height / design.height);
    canvas
      ..save()
      ..translate((size.width - design.width * scale) / 2, (size.height - design.height * scale) / 2)
      ..scale(scale);

    final body = VTBodyMapGeometry.body(figure, view);
    canvas
      ..drawPath(body, Paint()..color = bodyColor)
      ..save()
      ..clipPath(body);

    final highlightByPart = {for (final highlight in highlights) highlight.part: highlight};
    final definition = Paint()
      ..color = definitionColor
      ..style = .stroke
      ..strokeWidth = _definitionWidth;
    for (final part in VTBodyPart.values) {
      final fill = switch (highlightByPart[part]) {
        final VTBodyMapHighlight highlight => Paint()..color = highlight.color.withValues(alpha: _alphaFor(highlight.intensity)),
        null => null,
      };
      for (final path in VTBodyMapGeometry.partsOf(part, view, figure)) {
        if (fill != null) {
          canvas.drawPath(path, fill);
        }
        canvas.drawPath(path, definition);
      }
    }

    canvas
      ..restore()
      ..drawPath(
        body,
        Paint()
          ..color = outlineColor
          ..style = .stroke
          ..strokeWidth = _outlineWidth,
      )
      ..restore();
  }

  double _alphaFor(double intensity) =>
      ui.lerpDouble(VTBodyMap.minHighlightAlpha, VTBodyMap.maxHighlightAlpha, intensity.clamp(0, 1).toDouble())!;

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) =>
      oldDelegate.view != view ||
      oldDelegate.figure != figure ||
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.outlineColor != outlineColor ||
      oldDelegate.definitionColor != definitionColor ||
      !listEquals(oldDelegate.highlights, highlights);
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_geometry.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';

class VTBodyMap extends StatelessWidget {
  const VTBodyMap({required this.view, required this.highlights, this.height = 168, this.semanticLabel, super.key});

  static const double minHighlightAlpha = 0.35;
  static const double maxHighlightAlpha = 0.95;

  final VTBodyMapView view;
  final List<VTBodyMapHighlight> highlights;
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
              highlights: highlights,
              bodyColor: colorScheme.onSurface.withValues(alpha: 0.10),
              outlineColor: colorScheme.onSurface.withValues(alpha: 0.22),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({required this.view, required this.highlights, required this.bodyColor, required this.outlineColor});

  final VTBodyMapView view;
  final List<VTBodyMapHighlight> highlights;
  final Color bodyColor;
  final Color outlineColor;

  static const double _outlineWidth = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    const design = VTBodyMapGeometry.designSize;
    final scale = math.min(size.width / design.width, size.height / design.height);
    canvas
      ..save()
      ..translate((size.width - design.width * scale) / 2, (size.height - design.height * scale) / 2)
      ..scale(scale);

    final body = VTBodyMapGeometry.body();
    canvas.drawPath(body, Paint()..color = bodyColor);

    for (final highlight in highlights) {
      final paint = Paint()..color = highlight.color.withValues(alpha: _alphaFor(highlight.intensity));
      for (final path in VTBodyMapGeometry.partsOf(highlight.part, view)) {
        canvas.drawPath(Path.combine(PathOperation.intersect, body, path), paint);
      }
    }

    canvas
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
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.outlineColor != outlineColor ||
      !listEquals(oldDelegate.highlights, highlights);
}

import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Hands a widget's own pixels back as a PNG, so a screen can be exported as an
/// image without a rendering dependency: [VTCaptureBoundary] wraps the subtree in
/// a `RepaintBoundary` keyed by this controller, and [capture] reads it.
///
/// It returns null rather than throwing when the boundary is not in the tree —
/// a caller that cannot show what it captured is the one place that knows what
/// to say about it.
class VTCaptureController {
  final GlobalKey boundaryKey = GlobalKey();

  /// Three device pixels per logical pixel, so the export is sharp on a phone
  /// screen and large enough for a story surface whatever the device it was
  /// captured on — the size of the image must not depend on the display it was
  /// taken from.
  static const double defaultPixelRatio = 3;

  Future<Uint8List?> capture({double pixelRatio = defaultPixelRatio}) async {
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return null;
    }
    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final pngBytes = await image.toByteData(format: .png);
      return pngBytes?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}

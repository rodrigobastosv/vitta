import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';

abstract class VTBodyMapGeometry {
  static const Size designSize = Size(100, 200);

  static Path body() => _union([
    _oval(const Offset(50, 15), 9.2, 11.5),
    _rounded(const Rect.fromLTRB(45.2, 23, 54.8, 33), 3),
    _torso(),
    ..._mirrored(_muscle(const Offset(27.5, 50), 12, const Offset(22, 78), 9)),
    ..._mirrored(_muscle(const Offset(22.5, 77), 9, const Offset(18.5, 105), 6.5)),
    ..._mirrored(_oval(const Offset(17.4, 111), 4.2, 6)),
    ..._mirrored(_muscle(const Offset(43, 104), 18, const Offset(41.5, 149), 12)),
    ..._mirrored(_muscle(const Offset(41.5, 147), 12.5, const Offset(40, 181), 7)),
    ..._mirrored(_oval(const Offset(39, 186), 5.5, 5)),
  ]);

  static List<Path> partsOf(VTBodyPart part, VTBodyMapView view) => switch (view) {
    .front => _front(part),
    .back => _back(part),
  };

  static List<Path> _front(VTBodyPart part) => switch (part) {
    .neck => _mirrored(_muscle(const Offset(48.2, 27.5), 3.5, const Offset(45.5, 34), 4.5)),
    .traps => _mirrored(_frontTrap()),
    .shoulders => _mirrored(_oval(const Offset(28.5, 46), 7, 8.5)),
    .chest => _mirrored(_pectoral()),
    .abdominals => _abdominals(),
    .biceps => _mirrored(_muscle(const Offset(28.5, 54), 8.5, const Offset(24, 74), 6.5)),
    .forearms => _mirrored(_muscle(const Offset(23, 80), 7.5, const Offset(19, 104), 5)),
    .abductors => _mirrored(_muscle(const Offset(36.5, 99), 7, const Offset(36, 115), 5)),
    .quadriceps => _mirrored(_muscle(const Offset(43, 113), 11.5, const Offset(41.6, 145), 8)),
    .adductors => _mirrored(_muscle(const Offset(47.6, 113), 5, const Offset(46, 141), 3.5)),
    .calves => _mirrored(_muscle(const Offset(42, 153), 8, const Offset(40.5, 175), 5)),
    .lats || .middleBack || .lowerBack || .glutes || .hamstrings || .triceps => const [],
  };

  static List<Path> _back(VTBodyPart part) => switch (part) {
    .neck => [_rounded(const Rect.fromLTRB(46, 27, 54, 34), 2.5)],
    .traps => [_union(_mirrored(_halfBackTrap()))],
    .shoulders => _mirrored(_oval(const Offset(28.5, 46), 7, 8.5)),
    .lats => _mirrored(_lat()),
    .middleBack => _mirrored(_muscle(const Offset(47.2, 48), 4, const Offset(47.2, 64), 4.6)),
    .lowerBack => _mirrored(_muscle(const Offset(47.2, 66), 4.6, const Offset(46.8, 86), 3.6)),
    .triceps => _mirrored(_muscle(const Offset(28.5, 53), 9, const Offset(23.5, 75), 6.5)),
    .forearms => _mirrored(_muscle(const Offset(23, 80), 7.5, const Offset(19, 104), 5)),
    .glutes => _mirrored(_glute()),
    .abductors => _mirrored(_muscle(const Offset(35.8, 97), 6.5, const Offset(35.8, 112), 5)),
    .hamstrings => _mirrored(_muscle(const Offset(43, 114), 12, const Offset(41.6, 146), 8.5)),
    .adductors => _mirrored(_muscle(const Offset(48, 114), 4.6, const Offset(46.4, 142), 3.4)),
    .calves => _mirrored(_muscle(const Offset(41.8, 151), 10, const Offset(40, 177), 5.5)),
    .chest || .abdominals || .biceps || .quadriceps => const [],
  };

  static Path _torso() => _union(_mirrored(_halfTorso()));

  static Path _halfTorso() => Path()
    ..moveTo(50, 29)
    ..lineTo(41.5, 30.5)
    ..cubicTo(35.5, 32, 31, 35.5, 28, 40.5)
    ..cubicTo(24.8, 44.5, 24.2, 49.5, 25.8, 55)
    ..cubicTo(30, 56.5, 33.5, 58.5, 35, 62.5)
    ..cubicTo(36.5, 68.5, 36.8, 74, 37.5, 79)
    ..cubicTo(38, 84, 34.6, 88, 34.1, 95)
    ..cubicTo(33.7, 102, 35.6, 107, 39, 110.5)
    ..lineTo(50, 110.5)
    ..close();

  static Path _frontTrap() => Path()
    ..moveTo(46, 33.2)
    ..cubicTo(40, 34.2, 34.8, 36.6, 31.2, 41)
    ..cubicTo(32.4, 43.4, 33.6, 45, 35.2, 45.8)
    ..cubicTo(38.6, 41.6, 42.2, 39, 46.4, 37.8)
    ..close();

  static Path _halfBackTrap() => Path()
    ..moveTo(50, 31)
    ..lineTo(42, 32.5)
    ..cubicTo(36, 34, 31.5, 37, 29.2, 41.5)
    ..lineTo(35.5, 47)
    ..cubicTo(41, 47.5, 45.5, 49, 49, 51.5)
    ..lineTo(50, 51.5)
    ..close();

  static Path _lat() => Path()
    ..moveTo(34, 47)
    ..cubicTo(34.5, 58, 36.5, 68, 40.5, 77)
    ..cubicTo(42.4, 79.8, 43.8, 80.4, 45, 79.4)
    ..cubicTo(44, 69, 41.5, 58, 38.5, 49)
    ..close();

  static Path _pectoral() => Path()
    ..moveTo(49, 42)
    ..cubicTo(43, 42.2, 37.2, 43.6, 34.6, 46.6)
    ..cubicTo(34.3, 52, 36.6, 55.8, 41, 56.9)
    ..cubicTo(45.4, 57.4, 48.3, 55.8, 49, 53.4)
    ..close();

  static Path _glute() => Path()
    ..moveTo(48.6, 96.6)
    ..cubicTo(43.6, 96.6, 39.4, 98.8, 37.8, 102.4)
    ..cubicTo(37.6, 106.8, 40.6, 109.8, 45, 110.2)
    ..cubicTo(47.4, 110.2, 48.6, 108.8, 48.6, 106.6)
    ..close();

  static List<Path> _abdominals() => [
    for (final top in const [57.5, 64.0, 70.5, 77.0]) ..._mirrored(_rounded(Rect.fromLTRB(43.4, top, 49.2, top + 5.5), 1.5)),
  ];

  static Path _oval(Offset center, double radiusX, double radiusY) =>
      Path()..addOval(Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2));

  static Path _rounded(Rect rect, double radius) => Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  static Path _muscle(Offset from, double fromWidth, Offset to, double toWidth) {
    final direction = to - from;
    final length = direction.distance;
    final halfFrom = fromWidth / 2;
    final halfTo = toWidth / 2;
    final belly = (halfFrom + halfTo) / 2 * 1.12;
    final shape = Path()
      ..moveTo(-halfFrom, 0)
      ..quadraticBezierTo(0, -halfFrom * 0.9, halfFrom, 0)
      ..quadraticBezierTo(belly, length / 2, halfTo, length)
      ..quadraticBezierTo(0, length + halfTo * 0.9, -halfTo, length)
      ..quadraticBezierTo(-belly, length / 2, -halfFrom, 0)
      ..close();
    final transform = Matrix4.identity()
      ..translateByDouble(from.dx, from.dy, 0, 1)
      ..rotateZ(math.atan2(direction.dy, direction.dx) - math.pi / 2);
    return shape.transform(transform.storage);
  }

  static List<Path> _mirrored(Path path) {
    final flip = Matrix4.identity()
      ..translateByDouble(designSize.width, 0, 0, 1)
      ..scaleByDouble(-1, 1, 1, 1);
    return [path, path.transform(flip.storage)];
  }

  static Path _union(List<Path> paths) => paths.skip(1).fold(paths.first, (body, part) => Path.combine(PathOperation.union, body, part));
}

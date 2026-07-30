import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';

abstract class VTBodyMapGeometry {
  static const Size designSize = Size(100, 200);

  static Path body() {
    final parts = _bodyParts();
    return parts.skip(1).fold(parts.first, (body, part) => Path.combine(PathOperation.union, body, part));
  }

  static List<Path> _bodyParts() => [
    _oval(const Offset(50, 15), 10, 12.5),
    _rounded(const Rect.fromLTRB(45.5, 25, 54.5, 33), 2.5),
    _torso(),
    ..._mirrored(_oval(const Offset(31.5, 39), 8.5, 8)),
    ..._mirrored(_limb(const Offset(31.5, 41), const Offset(24.5, 74), 11)),
    ..._mirrored(_limb(const Offset(25, 69), const Offset(20, 100), 9)),
    ..._mirrored(_oval(const Offset(18.8, 103), 4.8, 6)),
    ..._mirrored(_limb(const Offset(44, 102), const Offset(41, 148), 17)),
    ..._mirrored(_limb(const Offset(41, 143), const Offset(39.5, 182), 11.5)),
    ..._mirrored(_oval(const Offset(39, 185), 5.5, 4.5)),
  ];

  static List<Path> partsOf(VTBodyPart part, VTBodyMapView view) => switch (view) {
    .front => _front(part),
    .back => _back(part),
  };

  static List<Path> _front(VTBodyPart part) => switch (part) {
    .chest => _mirrored(_roundedCorners(const Rect.fromLTRB(36, 37, 49.4, 54), topLeft: 6, topRight: 3, bottomLeft: 9, bottomRight: 6)),
    .core => [_rounded(const Rect.fromLTRB(41.5, 57, 58.5, 92), 7)],
    .shoulders => _mirrored(_oval(const Offset(31.5, 39), 7.5, 7)),
    .arms => [
      ..._mirrored(_limb(const Offset(31.5, 44), const Offset(26, 69), 9)),
      ..._mirrored(_limb(const Offset(25, 73), const Offset(21, 97), 7.5)),
    ],
    .legs => [
      ..._mirrored(_limb(const Offset(44, 104), const Offset(41.5, 143), 14)),
      ..._mirrored(_limb(const Offset(41, 150), const Offset(40, 178), 9)),
    ],
    .back => const [],
  };

  static List<Path> _back(VTBodyPart part) => switch (part) {
    .back => [_traps(), _lats(), _rounded(const Rect.fromLTRB(43, 82, 57, 98), 5)],
    .shoulders => _mirrored(_oval(const Offset(31.5, 39), 7.5, 7)),
    .arms => [
      ..._mirrored(_limb(const Offset(31.5, 44), const Offset(26, 69), 9)),
      ..._mirrored(_limb(const Offset(25, 73), const Offset(21, 97), 7.5)),
    ],
    .legs => [
      ..._mirrored(_oval(const Offset(45, 102), 6.5, 5.5)),
      ..._mirrored(_limb(const Offset(44, 108), const Offset(41.5, 144), 14)),
      ..._mirrored(_limb(const Offset(41, 150), const Offset(40, 176), 9)),
    ],
    .chest || .core => const [],
  };

  static Path _torso() => Path()
    ..moveTo(36, 32)
    ..lineTo(64, 32)
    ..quadraticBezierTo(69, 36, 67, 58)
    ..quadraticBezierTo(64, 76, 63, 88)
    ..lineTo(62, 104)
    ..lineTo(38, 104)
    ..lineTo(37, 88)
    ..quadraticBezierTo(36, 76, 33, 58)
    ..quadraticBezierTo(31, 36, 36, 32)
    ..close();

  static Path _traps() => Path()
    ..moveTo(50, 32)
    ..lineTo(63, 36)
    ..lineTo(57, 52)
    ..lineTo(43, 52)
    ..lineTo(37, 36)
    ..close();

  static Path _lats() => Path()
    ..moveTo(34, 49)
    ..quadraticBezierTo(37, 71, 46, 84)
    ..lineTo(54, 84)
    ..quadraticBezierTo(63, 71, 66, 49)
    ..close();

  static Path _oval(Offset center, double radiusX, double radiusY) =>
      Path()..addOval(Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2));

  static Path _rounded(Rect rect, double radius) => Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  static Path _roundedCorners(
    Rect rect, {
    required double topLeft,
    required double topRight,
    required double bottomLeft,
    required double bottomRight,
  }) => Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
    );

  static Path _limb(Offset from, Offset to, double width) {
    final direction = to - from;
    final capsule = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-width / 2, 0, width, direction.distance), Radius.circular(width / 2)));
    final transform = Matrix4.identity()
      ..translateByDouble(from.dx, from.dy, 0, 1)
      ..rotateZ(math.atan2(direction.dy, direction.dx) - math.pi / 2);
    return capsule.transform(transform.storage);
  }

  static List<Path> _mirrored(Path path) {
    final flip = Matrix4.identity()
      ..translateByDouble(designSize.width, 0, 0, 1)
      ..scaleByDouble(-1, 1, 1, 1);
    return [path, path.transform(flip.storage)];
  }
}

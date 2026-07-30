import 'package:flutter/widgets.dart';
import 'package:vitta/app/design_system/components/general/vt_capture_controller.dart';

class VTCaptureBoundary extends StatelessWidget {
  const VTCaptureBoundary({required this.controller, required this.child, super.key});

  final VTCaptureController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(key: controller.boundaryKey, child: child);
}

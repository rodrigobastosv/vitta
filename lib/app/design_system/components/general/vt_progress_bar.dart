import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTProgressBar extends StatelessWidget {
  const VTProgressBar({required this.value, this.minHeight = 8, super.key});

  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: VTRadius.borderRadiusS,
    child: LinearProgressIndicator(value: value.clamp(0, 1).toDouble(), minHeight: minHeight),
  );
}

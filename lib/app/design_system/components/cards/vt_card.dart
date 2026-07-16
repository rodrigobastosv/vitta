import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTCard extends StatelessWidget {
  const VTCard({required this.child, this.onTap, this.color, this.padding = const EdgeInsets.all(VTSpacing.m), super.key});

  final Widget child;
  final VoidCallback? onTap;

  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: InkWell(
      onTap: onTap,
      borderRadius: VTRadius.borderRadiusM,
      child: Padding(padding: padding, child: child),
    ),
  );
}

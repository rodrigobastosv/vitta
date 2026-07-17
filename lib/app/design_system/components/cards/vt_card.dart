import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTCard extends StatelessWidget {
  const VTCard({required this.child, this.onTap, this.color, this.padding = const EdgeInsets.all(VTSpacing.m), super.key});

  final Widget child;
  final VoidCallback? onTap;

  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = color ?? (isDark ? VTColors.cardDark : VTColors.cardLight);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: VTRadius.borderRadiusL,
        border: Border.all(color: colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: VTRadius.borderRadiusL,
        child: InkWell(
          onTap: onTap,
          borderRadius: VTRadius.borderRadiusL,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTSwipeToDelete extends StatelessWidget {
  const VTSwipeToDelete({required this.itemKey, required this.onDelete, required this.child, super.key});

  final Key itemKey;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: itemKey,
    direction: .endToStart,
    onDismissed: (_) {
      VTHaptics.warning();
      onDelete();
    },
    background: DecoratedBox(
      decoration: const BoxDecoration(color: VTColors.error, borderRadius: VTRadius.borderRadiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
        child: Align(
          alignment: .centerRight,
          child: Icon(Icons.delete_outline, color: VTColors.inkOn(VTColors.error), semanticLabel: context.l10n.delete),
        ),
      ),
    ),
    child: child,
  );
}

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTDragHandle extends StatelessWidget {
  const VTDragHandle({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.reorderHandleLabel,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.xs, vertical: VTSpacing.s),
      child: Icon(Icons.drag_indicator, size: 22, color: context.colorScheme.onSurfaceVariant),
    ),
  );
}

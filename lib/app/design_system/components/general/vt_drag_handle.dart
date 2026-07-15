import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

/// The grip that starts a drag in a ReorderableListView.
///
/// Exists because the default handles only appear on desktop: on a touch
/// platform a ReorderableListView is drag-on-long-press with no affordance at
/// all, so a list looks immovable. It also keeps the drag off the row itself,
/// which matters whenever the row is already tappable (a VTCard with onTap) -
/// a long press there is ambiguous between "edit" and "drag", and the tap
/// recognizer usually wins.
///
/// Wrap it in ReorderableDragStartListener at the call site (it needs the
/// item's index) and pass `buildDefaultDragHandles: false` to the list.
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

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_swipe_actions.dart';

// Delete-only swipe: a thin wrapper over VTSwipeActions with no leading action, so
// it stays endToStart-only (a bidirectional Dismissible turns a mis-aimed
// horizontal scroll into a deletion). Reach for VTSwipeActions when a row also
// needs a non-destructive swipe (e.g. complete).
class VTSwipeToDelete extends StatelessWidget {
  const VTSwipeToDelete({required this.itemKey, required this.onDelete, required this.child, super.key});

  final Key itemKey;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) => VTSwipeActions(itemKey: itemKey, onDelete: onDelete, deleteLabel: context.l10n.delete, child: child);
}

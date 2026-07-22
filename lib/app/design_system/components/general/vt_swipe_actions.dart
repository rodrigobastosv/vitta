import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

// A swipeable row: a swipe from the end (endToStart) always deletes; an optional
// [leading] action fires on a start-to-end swipe and snaps the row back
// (confirmDismiss returns false), so it can perform a non-destructive action like
// completing without removing the row. Delete stays the only *destructive*
// direction - the both-directions-delete trap the endToStart-only rule guards
// against does not apply here, because the two directions do different things.
class VTSwipeActions extends StatelessWidget {
  const VTSwipeActions({required this.itemKey, required this.onDelete, required this.deleteLabel, required this.child, this.leading, super.key});

  final Key itemKey;
  final VoidCallback onDelete;
  final String deleteLabel;
  final Widget child;
  final VTSwipeAction? leading;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final deleteBackground = _background(alignment: .centerRight, icon: Icons.delete_outline, color: VTColors.error, semanticLabel: deleteLabel);
    return Dismissible(
      key: itemKey,
      direction: leading == null ? .endToStart : .horizontal,
      background: leading == null
          ? deleteBackground
          : _background(alignment: .centerLeft, icon: leading.icon, color: leading.color, semanticLabel: leading.semanticLabel),
      secondaryBackground: leading == null ? null : deleteBackground,
      confirmDismiss: (direction) async {
        if (direction == .startToEnd) {
          leading!.onTrigger();
          return false;
        }
        return true;
      },
      onDismissed: (_) {
        VTHaptics.warning();
        onDelete();
      },
      child: child,
    );
  }

  Widget _background({required Alignment alignment, required IconData icon, required Color color, required String semanticLabel}) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: VTRadius.borderRadiusS),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
      child: Align(alignment: alignment, child: Icon(icon, color: VTColors.inkOn(color), semanticLabel: semanticLabel)),
    ),
  );
}

class VTSwipeAction {
  const VTSwipeAction({required this.onTrigger, required this.icon, required this.color, required this.semanticLabel});

  final VoidCallback onTrigger;
  final IconData icon;
  final Color color;
  final String semanticLabel;
}

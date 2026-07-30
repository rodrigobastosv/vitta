import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// One of the ways to add food, as a labelled target rather than a bare app-bar
/// glyph. Three unlabelled icons in the app bar left "photograph it" and "type
/// it in" as things you had to already know about.
class AddFoodActionButton extends StatelessWidget {
  const AddFoodActionButton({required this.icon, required this.label, required this.onTap, this.isLocked = false, super.key});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// A premium action the user is not entitled to yet. It stays tappable — the
  /// tap opens the paywall — so the badge explains rather than blocks.
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: VTRadius.borderRadiusM,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: VTSpacing.minTapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
            child: Column(
              mainAxisSize: .min,
              children: [
                if (isLocked)
                  Badge(backgroundColor: VTColors.premium, smallSize: 8, child: Icon(icon, color: colorScheme.primary))
                else
                  Icon(icon, color: colorScheme.primary),
                const VTGap.xs(),
                Text(
                  label,
                  style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

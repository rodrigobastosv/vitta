import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({required this.label, required this.isSelected, required this.onSelected, super.key});

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          VTHaptics.selection();
        }
        onSelected();
      },
      borderRadius: VTRadius.borderRadiusM,
      child: AnimatedContainer(
        duration: VTMotion.transition,
        curve: VTMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s + VTSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: VTRadius.borderRadiusM,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: VTTextStyles.body(context).copyWith(
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  fontWeight: isSelected ? .w600 : .w400,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, size: 20, color: colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}

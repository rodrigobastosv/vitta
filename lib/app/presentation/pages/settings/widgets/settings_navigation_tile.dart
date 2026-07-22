import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class SettingsNavigationTile extends StatelessWidget {
  const SettingsNavigationTile({required this.icon, required this.title, required this.hint, required this.onTap, super.key});

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: .center,
            decoration: BoxDecoration(color: colorScheme.primary, shape: .circle),
            child: Icon(icon, size: 20, color: VTColors.inkOn(colorScheme.primary)),
          ),
          const VTGap.s(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(title, style: VTTextStyles.bodyStrong(context)),
                Text(hint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

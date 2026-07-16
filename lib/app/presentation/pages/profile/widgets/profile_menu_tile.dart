import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), shape: .circle),
            child: Icon(icon, color: accent, size: 22),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(title, style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(subtitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

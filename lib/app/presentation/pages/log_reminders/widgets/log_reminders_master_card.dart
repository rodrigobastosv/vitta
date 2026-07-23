import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class LogRemindersMasterCard extends StatelessWidget {
  const LogRemindersMasterCard({required this.isEnabled, required this.onChanged, super.key});

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: .center,
            decoration: BoxDecoration(color: colorScheme.primary, shape: .circle),
            child: Icon(Icons.notifications_active_outlined, size: 20, color: VTColors.inkOn(colorScheme.primary)),
          ),
          const VTGap.s(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.logRemindersMasterLabel, style: VTTextStyles.bodyStrong(context)),
                Text(l10n.logRemindersMasterHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(value: isEnabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

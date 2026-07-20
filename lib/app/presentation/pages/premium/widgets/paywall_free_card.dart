import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class PaywallFreeCard extends StatelessWidget {
  const PaywallFreeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: colorScheme.primary, size: 20),
              const VTGap.s(),
              Expanded(child: Text(l10n.premiumFreeTitle, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.s(),
          Text(l10n.premiumFreeMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class PaywallActiveCard extends StatelessWidget {
  const PaywallActiveCard({this.expiresAt, super.key});

  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final renewal = expiresAt;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: VTColors.success, size: 20),
              const VTGap.s(),
              Expanded(child: Text(l10n.premiumActiveTitle, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.s(),
          Text(l10n.premiumActiveMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
          if (renewal != null) ...[
            const VTGap.s(),
            Text(
              l10n.premiumRenewsOn(DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag()).format(renewal)),
              style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

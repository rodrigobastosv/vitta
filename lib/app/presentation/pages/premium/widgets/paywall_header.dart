import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class PaywallHeader extends StatelessWidget {
  const PaywallHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: VTColors.premium.withValues(alpha: 0.16),
              child: const Icon(Icons.workspace_premium_outlined, size: 32, color: VTColors.premium),
            ),
            const VTGap.l(),
            Expanded(child: Text(l10n.premiumTitle, style: VTTextStyles.headline(context))),
          ],
        ),
        const VTGap.s(),
        Text(l10n.premiumTagline, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

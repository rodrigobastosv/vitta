import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// The disc is solid premium with VTColors.inkOn, not the 16%-tint-with-the-
// accent-on-top shortcut it used to be: measured on the app's own card, that
// tint carries the premium icon at 2.76:1 in light, under the 3:1 non-text
// floor. The solid disc reads 5.10:1. Same trap the accent-avatar section of
// CLAUDE.md documents; premium was simply never in that table.
//
// Centred rather than a left-aligned row, because this is a conversion surface
// and the mark is the first thing that should land.
class PaywallHeader extends StatelessWidget {
  const PaywallHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: VTColors.premium,
          child: Icon(Icons.workspace_premium_outlined, size: 38, color: VTColors.inkOn(VTColors.premium)),
        ),
        const VTGap.m(),
        Text(l10n.premiumTitle, textAlign: .center, style: VTTextStyles.display(context)),
        const VTGap.s(),
        Text(
          l10n.premiumTagline,
          textAlign: .center,
          style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

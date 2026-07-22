import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class ProgressPhotoPrivacyNote extends StatelessWidget {
  const ProgressPhotoPrivacyNote({super.key});

  static const double _avatarSize = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            alignment: .center,
            decoration: const BoxDecoration(color: VTColors.green, shape: .circle),
            child: Icon(Icons.lock_outline, color: VTColors.inkOn(VTColors.green), size: 22),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.progressPhotosPrivacyTitle, style: VTTextStyles.title(context)),
                const VTGap.xs(),
                Text(
                  l10n.progressPhotosPrivacyMessage,
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

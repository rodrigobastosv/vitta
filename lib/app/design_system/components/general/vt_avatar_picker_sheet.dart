import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_avatar_catalog.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

Future<String?> showAvatarPickerSheet({required BuildContext context}) =>
    showModalBottomSheet<String>(context: context, builder: (sheetContext) => const VTAvatarPickerSheet());

/// A grid of preset avatars to choose from (issue #117). Taps pop the chosen
/// option's id.
class VTAvatarPickerSheet extends StatelessWidget {
  const VTAvatarPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(l10n.profileAvatarPickerTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              mainAxisSpacing: VTSpacing.m,
              crossAxisSpacing: VTSpacing.m,
              children: [
                for (final option in VTAvatarCatalog.options)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(option.id),
                    child: VTAvatarCatalog.buildAvatar(option, size: 56),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

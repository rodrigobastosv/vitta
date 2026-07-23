import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class LogRemindersTrackersCard extends StatelessWidget {
  const LogRemindersTrackersCard({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return VTCard(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.s),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: VTSpacing.s, top: VTSpacing.s, bottom: VTSpacing.xs),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: .center,
                  decoration: BoxDecoration(color: colorScheme.primary, shape: .circle),
                  child: Icon(Icons.schedule_outlined, size: 20, color: VTColors.inkOn(colorScheme.primary)),
                ),
                const VTGap.s(),
                Text(title, style: VTTextStyles.bodyStrong(context)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

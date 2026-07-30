import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';

// A solid coral pill rather than the 16% tint VTBadge uses: this one carries a
// glyph, and an accent icon on its own tint is exactly the combination the
// contrast floor rules out - coral reads 2.54:1 that way on a light card.
class DietStreakChip extends StatelessWidget {
  const DietStreakChip({required this.streak, super.key});

  static const _accent = VTColors.coral;

  final LoggingStreak streak;

  @override
  Widget build(BuildContext context) {
    final ink = VTColors.inkOn(_accent);
    return Tooltip(
      message: context.l10n.dietStreakTooltip(streak.days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
        decoration: const BoxDecoration(color: _accent, borderRadius: VTRadius.borderRadiusFull),
        child: Row(
          mainAxisSize: .min,
          children: [
            Icon(Icons.local_fire_department_rounded, size: 16, color: ink),
            const VTGap.xs(),
            Text(
              '${streak.days}',
              style: VTTextStyles.caption(context).copyWith(color: ink, fontWeight: .w700),
            ),
          ],
        ),
      ),
    );
  }
}

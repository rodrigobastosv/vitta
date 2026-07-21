import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SleepQualitySelector extends StatelessWidget {
  const SleepQualitySelector({required this.rating, required this.onChanged, super.key});

  final int? rating;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = rating ?? 0;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          mainAxisAlignment: .center,
          children: [
            for (var index = 1; index <= 5; index++)
              IconButton(
                iconSize: 34,
                visualDensity: .comfortable,
                tooltip: l10n.sleepQualityStars(index),
                onPressed: () {
                  VTHaptics.selection();
                  onChanged(rating == index ? null : index);
                },
                icon: Icon(index <= selected ? Icons.star_rounded : Icons.star_outline_rounded, color: VTColors.sleep),
              ),
          ],
        ),
        const VTGap.xs(),
        Center(
          child: Text(
            rating == null ? l10n.sleepQualityLabel : _description(l10n, rating!),
            style: rating == null
                ? VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)
                : VTTextStyles.bodyStrong(context).copyWith(color: VTColors.sleep),
          ),
        ),
      ],
    );
  }

  String _description(AppLocalizations l10n, int rating) => switch (rating) {
    1 => l10n.sleepQualityPoor,
    2 => l10n.sleepQualityFair,
    3 => l10n.sleepQualityGood,
    4 => l10n.sleepQualityGreat,
    _ => l10n.sleepQualityExcellent,
  };
}

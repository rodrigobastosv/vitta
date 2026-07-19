import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_entry.dart';

class ScannedMealItemCard extends StatefulWidget {
  const ScannedMealItemCard({required this.entry, required this.onGramsChanged, required this.onToggle, super.key});

  final MealScanEntry entry;
  final ValueChanged<String> onGramsChanged;
  final VoidCallback onToggle;

  @override
  State<ScannedMealItemCard> createState() => _ScannedMealItemCardState();
}

class _ScannedMealItemCardState extends State<ScannedMealItemCard> {
  late final TextEditingController _controller = TextEditingController(text: widget.entry.gramsText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final entry = widget.entry;
    final nameColor = entry.isIncluded ? colorScheme.onSurface : colorScheme.onSurfaceVariant;
    return VTCard(
      onTap: widget.onToggle,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Checkbox(value: entry.isIncluded, onChanged: (_) => widget.onToggle()),
          const VTGap.s(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(entry.item.name, style: VTTextStyles.bodyStrong(context).copyWith(color: nameColor)),
                const VTGap.s(),
                Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: TextField(
                        controller: _controller,
                        enabled: entry.isIncluded,
                        onChanged: widget.onGramsChanged,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: l10n.dietGramsUnit,
                          contentPadding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.s),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: VTRadius.borderRadiusM,
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (entry.isIncluded)
                      VTBadge(label: l10n.dietMealCalories(entry.calories.round()), color: colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

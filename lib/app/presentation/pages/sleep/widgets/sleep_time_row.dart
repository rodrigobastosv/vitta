import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class SleepTimeRow extends StatelessWidget {
  const SleepTimeRow({required this.icon, required this.label, required this.dateTime, required this.onTap, super.key});

  final IconData icon;
  final String label;
  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = context.materialLocalizations;
    return Material(
      color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: VTRadius.borderRadiusL,
      child: InkWell(
        onTap: onTap,
        borderRadius: VTRadius.borderRadiusL,
        child: Padding(
          padding: const EdgeInsets.all(VTSpacing.m),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: .center,
                decoration: BoxDecoration(color: VTColors.sleep.withValues(alpha: 0.16), shape: .circle),
                child: Icon(icon, color: VTColors.sleep, size: 18),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(label, style: VTTextStyles.overline(context)),
                    Text(
                      '${materialLocalizations.formatShortDate(dateTime)} · ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime))}',
                      style: VTTextStyles.bodyStrong(context),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: context.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class RestSoundCard extends StatelessWidget {
  const RestSoundCard({required this.isEnabled, required this.onChanged, super.key});

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    const accent = VTColors.coral;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: .center,
                decoration: const BoxDecoration(color: accent, shape: .circle),
                child: Icon(Icons.volume_up_outlined, size: 20, color: VTColors.inkOn(accent)),
              ),
              const VTGap.s(),
              Expanded(child: Text(l10n.workoutRestSoundLabel, style: VTTextStyles.bodyStrong(context))),
              Switch(value: isEnabled, onChanged: onChanged),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.workoutRestSoundHint, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

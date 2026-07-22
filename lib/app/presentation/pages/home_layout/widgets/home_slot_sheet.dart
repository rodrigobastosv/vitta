import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';
import 'package:vitta/app/presentation/general/home_feature_labels.dart';
import 'package:vitta/app/presentation/general/home_slot_labels.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_tile.dart';

Future<HomeSlot?> showHomeSlotSheet(BuildContext context, {required HomeFeature feature, required HomeSlot slot}) => showModalBottomSheet<HomeSlot>(
  context: context,
  isScrollControlled: true,
  builder: (context) => HomeSlotSheet(feature: feature, slot: slot),
);

class HomeSlotSheet extends StatelessWidget {
  const HomeSlotSheet({required this.feature, required this.slot, super.key});

  final HomeFeature feature;
  final HomeSlot slot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          children: [
            Text(l10n.homeLayoutSlotQuestion(feature.label(l10n)), style: VTTextStyles.title(context)),
            const VTGap.m(),
            for (final option in HomeSlot.values)
              SettingsOptionTile(
                label: option.label(l10n),
                isSelected: option == slot,
                onSelected: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
  }
}

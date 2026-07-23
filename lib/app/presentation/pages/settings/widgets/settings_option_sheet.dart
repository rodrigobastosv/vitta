import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_tile.dart';

Future<SettingsOption<T>?> showSettingsOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SettingsOption<T>> options,
  required T selected,
}) => showModalBottomSheet<SettingsOption<T>>(
  context: context,
  isScrollControlled: true,
  builder: (context) => SettingsOptionSheet<T>(title: title, options: options, selected: selected),
);

class SettingsOptionSheet<T> extends StatelessWidget {
  const SettingsOptionSheet({required this.title, required this.options, required this.selected, super.key});

  final String title;
  final List<SettingsOption<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(VTSpacing.m),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        children: [
          Text(title, style: VTTextStyles.title(context)),
          const VTGap.m(),
          for (final option in options)
            SettingsOptionTile(
              label: option.label,
              isSelected: option.value == selected,
              onSelected: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}

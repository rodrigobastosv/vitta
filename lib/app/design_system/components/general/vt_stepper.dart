import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTStepper extends StatelessWidget {
  const VTStepper({required this.controller, this.min = 1, this.step = 1, this.suffixLabel, this.autofocus = false, super.key});

  final TextEditingController controller;
  final int min;
  final int step;
  final String? suffixLabel;
  final bool autofocus;

  double get _current => double.tryParse(controller.text.replaceAll(',', '.')) ?? min.toDouble();

  double get _incremented => _current.floorToDouble() + step;
  double get _decremented => _current.ceilToDouble() - step;

  void _setValue(double value) {
    VTHaptics.selection();
    final clamped = value < min ? min.toDouble() : value;
    final text = QuantityFormat.format(clamped);
    controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      shape: const CircleBorder(),
    );
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: VTRadius.borderRadiusM),
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.xs),
        child: Row(
          mainAxisSize: .min,
          children: [
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, _) => IconButton(
                onPressed: _decremented >= min ? () => _setValue(_decremented) : null,
                icon: const Icon(Icons.remove_rounded),
                style: buttonStyle,
                visualDensity: .compact,
              ),
            ),
            SizedBox(
              width: 40,
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                textAlign: .center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: VTTextStyles.title(context),
                decoration: const InputDecoration(
                  filled: false,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: VTSpacing.s),
                ),
              ),
            ),
            if (suffixLabel case final suffixLabel?) ...[
              const VTGap.xs(),
              Text(suffixLabel, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
            ],
            IconButton(
              onPressed: () => _setValue(_incremented),
              icon: const Icon(Icons.add_rounded),
              style: buttonStyle,
              visualDensity: .compact,
            ),
          ],
        ),
      ),
    );
  }
}

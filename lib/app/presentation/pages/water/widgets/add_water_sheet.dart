import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/water/water_cubit.dart';

const _quickAddPresetsMl = [200.0, 300.0, 500.0, 750.0];

Future<void> showAddWaterSheet({required BuildContext context, required UnitSystem unitSystem}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(
    value: context.read<WaterCubit>(),
    child: _AddWaterSheet(unitSystem: unitSystem),
  ),
);

class _AddWaterSheet extends StatefulWidget {
  const _AddWaterSheet({required this.unitSystem});

  final UnitSystem unitSystem;

  @override
  State<_AddWaterSheet> createState() => _AddWaterSheetState();
}

class _AddWaterSheetState extends State<_AddWaterSheet> {
  final _amountController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addWater(double amountMl) async {
    await context.read<WaterCubit>().addWater(amountMl: amountMl);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _addCustomAmount() {
    final displayValue = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final l10n = context.l10n;
    if (displayValue == null || displayValue <= 0) {
      setState(() => _errorMessage = l10n.waterInvalidAmount);
      return;
    }
    _addWater(widget.unitSystem.displayVolumeToMilliliters(displayValue));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.waterQuickAddTitle, style: VTTextStyles.title(context)),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              for (final presetMl in _quickAddPresetsMl)
                ActionChip(
                  label: Text('${widget.unitSystem.millilitersToDisplayVolume(presetMl).round()} ${widget.unitSystem.volumeUnitLabel}'),
                  onPressed: () => _addWater(presetMl),
                ),
            ],
          ),
          const VTGap.l(),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.waterCustomAmountLabel(widget.unitSystem.volumeUnitLabel)),
          ),
          if (_errorMessage case final errorMessage?) ...[
            const VTGap.s(),
            Text(errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.waterLogAction, onPressed: _addCustomAmount),
        ],
      ),
    );
  }
}

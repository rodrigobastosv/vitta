import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_weight_picker.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/presentation/pages/body_weight/body_weight_cubit.dart';

Future<void> showLogBodyWeightSheet({required BuildContext context}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.logBodyWeight.settings,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<BodyWeightCubit>(), child: const _LogBodyWeightSheet()),
);

class _LogBodyWeightSheet extends StatefulWidget {
  const _LogBodyWeightSheet();

  @override
  State<_LogBodyWeightSheet> createState() => _LogBodyWeightSheetState();
}

class _LogBodyWeightSheetState extends State<_LogBodyWeightSheet> {
  // Default the picker to the last logged weight, or a sensible mid-range weight
  // (70 kg) when there's no history yet - both expressed in kilograms and converted
  // to the reader's unit for the ruler.
  static const double _defaultKg = 70;
  static const double _minKg = 30;
  static const double _maxKg = 250;

  late final UnitSystem _unitSystem = context.read<BodyWeightCubit>().unitSystem;
  late double _displayWeight = _unitSystem.kilogramsToDisplayLoad(context.read<BodyWeightCubit>().state.latest?.weightKg ?? _defaultKg);
  DateTime _date = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final cubit = context.read<BodyWeightCubit>();
    final loggedDate = DateTime(_date.year, _date.month, _date.day);
    await cubit.logWeight(loggedDate: loggedDate, weightKg: _unitSystem.displayLoadToKilograms(_displayWeight));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(left: VTSpacing.m, right: VTSpacing.m, top: VTSpacing.m, bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.bodyWeightLogAction, style: VTTextStyles.title(context)),
          const VTGap.l(),
          VTWeightPicker(
            initialValue: _displayWeight,
            onChanged: (value) => _displayWeight = value,
            unitLabel: _unitSystem.loadUnitLabel,
            min: _unitSystem.kilogramsToDisplayLoad(_minKg),
            max: _unitSystem.kilogramsToDisplayLoad(_maxKg),
            step: _unitSystem == UnitSystem.metric ? 0.1 : 0.2,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.bodyWeightDateLabel),
            subtitle: Text(context.materialLocalizations.formatShortDate(_date)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _pickDate,
          ),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.bodyWeightLogAction, onPressed: _submit),
        ],
      ),
    );
  }
}

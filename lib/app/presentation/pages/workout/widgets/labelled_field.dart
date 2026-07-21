import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// Both inputs wear the same label so the row reads as one control pair. The
/// stepper cannot use InputDecoration's floating label - it has no text baseline
/// to float against, so the label lands on top of the buttons.
class LabelledField extends StatelessWidget {
  const LabelledField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    mainAxisSize: .min,
    children: [
      Text(label, style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
      const VTGap.xs(),
      child,
    ],
  );
}

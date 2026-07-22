import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

// A circular checkbox that fills and springs its check in on completion rather
// than just redrawing - the satisfying half of ticking a reminder (the burst is
// the other half). Passing a null onChanged renders it read-only. The 28px disc
// sits in a 44px tap target.
class VTCheckCircle extends StatelessWidget {
  const VTCheckCircle({required this.value, required this.onChanged, this.color = VTColors.success, super.key});

  static const double _size = 28;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      checked: value,
      child: InkResponse(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        radius: _size,
        child: Padding(
          padding: const EdgeInsets.all(VTSpacing.s),
          child: AnimatedContainer(
            duration: VTMotion.transition,
            curve: VTMotion.curve,
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: .circle,
              color: value ? color : Colors.transparent,
              border: Border.all(color: value ? color : colorScheme.onSurfaceVariant, width: 2),
            ),
            child: AnimatedScale(
              scale: value ? 1 : 0,
              duration: VTMotion.transition,
              curve: VTMotion.curve,
              child: Icon(Icons.check_rounded, size: _size - 8, color: VTColors.inkOn(color)),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

/// A slider that can also be nudged one [step] at a time.
///
/// A bare `Slider` over a wide range is unusable for a figure anyone actually
/// means: the macro goals span up to 600 g and the calorie target 4,200 kcal, so
/// on a phone a pixel of thumb travel is worth about 2 g or 25 kcal and landing
/// on a round number is luck. Two things fix that together — the drag **snaps to
/// [step]**, so it can only ever produce a figure worth typing, and the flanking
/// −/+ buttons move it exactly one step, which is the only way to reach a
/// specific value with a finger.
///
/// The buttons disable at the bounds rather than silently doing nothing, and the
/// tick marks a divided `Slider` would otherwise draw are hidden: at 120
/// divisions they are visual noise, not a scale anyone reads.
class VTAdjustableSlider extends StatelessWidget {
  const VTAdjustableSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.onChanged,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    super.key,
  }) : assert(step > 0, 'A step of zero would divide the track into nothing.');

  final double value;
  final double min;
  final double max;
  final double step;
  final Color color;
  final ValueChanged<double> onChanged;
  final String decreaseTooltip;
  final String increaseTooltip;

  double get _clamped => value.clamp(min, max);

  double _snap(double raw) => (((raw - min) / step).round() * step + min).clamp(min, max);

  void _emit(double raw) {
    final snapped = _snap(raw);
    if (snapped == _clamped) {
      return;
    }
    VTHaptics.selection();
    onChanged(snapped);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: _clamped > min ? () => _emit(_clamped - step) : null,
        icon: const Icon(Icons.remove),
        tooltip: decreaseTooltip,
        constraints: const BoxConstraints(minWidth: VTSpacing.minTapTarget, minHeight: VTSpacing.minTapTarget),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
            inactiveTrackColor: color.withValues(alpha: 0.20),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            trackHeight: 4,
          ),
          child: Slider(
            value: _clamped,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            onChanged: _emit,
          ),
        ),
      ),
      IconButton(
        onPressed: _clamped < max ? () => _emit(_clamped + step) : null,
        icon: const Icon(Icons.add),
        tooltip: increaseTooltip,
        constraints: const BoxConstraints(minWidth: VTSpacing.minTapTarget, minHeight: VTSpacing.minTapTarget),
      ),
    ],
  );
}

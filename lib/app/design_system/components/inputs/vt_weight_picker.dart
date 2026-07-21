import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// A horizontal ruler the user scrolls to dial in a weight, with a fixed centre
// pointer and a big read-out above it (issue #101). Owned rather than pulled from a
// package, the same call the charts make - the interaction is simple and the look
// should be ours. It is unit-agnostic: the caller works in display units (kg or lb)
// and passes the matching bounds, step and label, so kg/lb both flow through one
// widget.
class VTWeightPicker extends StatefulWidget {
  const VTWeightPicker({
    required this.initialValue,
    required this.onChanged,
    required this.unitLabel,
    required this.min,
    required this.max,
    this.step = 0.1,
    super.key,
  });

  final double initialValue;
  final ValueChanged<double> onChanged;
  final String unitLabel;
  final double min;
  final double max;
  final double step;

  @override
  State<VTWeightPicker> createState() => _VTWeightPickerState();
}

class _VTWeightPickerState extends State<VTWeightPicker> {
  static const double _tickSpacing = 10;
  static const double _rulerHeight = 64;

  ScrollController? _controller;
  late final int _tickCount = ((widget.max - widget.min) / widget.step).round() + 1;
  late final int _ticksPerMajor = (1 / widget.step).round();
  late double _value = widget.initialValue.clamp(widget.min, widget.max);

  int _indexFor(double value) => ((value - widget.min) / widget.step).round().clamp(0, _tickCount - 1);

  double _valueFor(int index) => widget.min + index * widget.step;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = _controller;
    if (controller == null || !controller.hasClients) {
      return;
    }
    final index = (controller.offset / _tickSpacing).round().clamp(0, _tickCount - 1);
    final value = _valueFor(index);
    if ((value - _value).abs() >= widget.step / 2) {
      VTHaptics.selection();
      setState(() => _value = value);
      widget.onChanged(value);
    }
  }

  void _snap() {
    final controller = _controller;
    if (controller == null || !controller.hasClients) {
      return;
    }
    final index = (controller.offset / _tickSpacing).round().clamp(0, _tickCount - 1);
    final target = index * _tickSpacing;
    // Already on a tick - bail out, otherwise animateTo fires another
    // ScrollEndNotification and _snap recurses forever.
    if ((controller.offset - target).abs() < 0.5) {
      return;
    }
    controller.animateTo(target, duration: VTMotion.micro, curve: VTMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .baseline,
          textBaseline: .alphabetic,
          children: [
            Text(_format(_value), style: VTTextStyles.display(context)),
            const SizedBox(width: 4),
            Text(widget.unitLabel, style: VTTextStyles.title(context).copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        SizedBox(
          height: _rulerHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _controller ??= ScrollController(initialScrollOffset: _indexFor(_value) * _tickSpacing);
              final sidePadding = constraints.maxWidth / 2 - _tickSpacing / 2;
              return Stack(
                alignment: Alignment.center,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        _onScroll();
                      } else if (notification is ScrollEndNotification) {
                        _snap();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      itemExtent: _tickSpacing,
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      itemCount: _tickCount,
                      itemBuilder: (context, index) => _Tick(
                        label: index % _ticksPerMajor == 0 ? _valueFor(index).round().toString() : null,
                        color: colorScheme.onSurfaceVariant,
                        slotWidth: _tickSpacing,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Container(width: 3, height: 40, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2))),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _format(double value) {
    final rounded = value.round();
    return (value - rounded).abs() < widget.step / 2 ? '$rounded' : value.toStringAsFixed(1);
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.color, required this.slotWidth, this.label});

  final Color color;
  final double slotWidth;
  final String? label;

  static const double _labelWidth = 48;

  @override
  Widget build(BuildContext context) {
    final isMajor = label != null;
    // A Stack rather than a Column so nothing lives in a Flex (a tick lands in a
    // narrow slot, and a major label is wider than that): Stack + Clip.none lets the
    // label overflow the slot. The label is a Positioned box wider than the slot,
    // centred on the tick - a non-positioned child would be squeezed to the slot
    // width and clip its own text.
    return Stack(
      clipBehavior: .none,
      alignment: .bottomCenter,
      children: [
        Container(width: 1.5, height: isMajor ? 24 : 12, color: color.withValues(alpha: isMajor ? 0.9 : 0.4)),
        if (isMajor)
          Positioned(
            bottom: 28,
            left: (slotWidth - _labelWidth) / 2,
            width: _labelWidth,
            child: Text(label!, textAlign: .center, softWrap: false, style: VTTextStyles.overline(context).copyWith(color: color)),
          ),
      ],
    );
  }
}

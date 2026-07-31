import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTRestTimer extends StatefulWidget {
  const VTRestTimer({
    required this.remaining,
    required this.progress,
    required this.onExtend,
    required this.onShorten,
    required this.onSkip,
    this.label,
    this.onConfigure,
    super.key,
  });

  /// How far behind the leading colour the trailing one sits on the ramp, so the
  /// two stops are always different and always both readable against the ink.
  static const double gradientLag = 0.18;

  static const Duration sweep = Duration(milliseconds: 2600);
  static const Duration colorGlide = Duration(seconds: 1);

  /// Green while there is time, amber as it runs down, red at the end. Every
  /// stop along the lerp clears 4.5:1 against white, so the ink never changes.
  static Color colorAt(double progress) => switch (progress.clamp(0, 1).toDouble()) {
    final value when value > 0.5 => Color.lerp(VTColors.warningStrong, VTColors.green, (value - 0.5) * 2)!,
    final value => Color.lerp(VTColors.error, VTColors.warningStrong, value * 2)!,
  };

  static Color trailingColorAt(double progress) => colorAt(progress - gradientLag);

  final Duration remaining;
  final double progress;
  final VoidCallback onExtend;
  final VoidCallback onShorten;
  final VoidCallback onSkip;
  final String? label;
  final VoidCallback? onConfigure;

  @override
  State<VTRestTimer> createState() => _VTRestTimerState();
}

class _VTRestTimerState extends State<VTRestTimer> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(vsync: this, duration: VTRestTimer.sweep);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  String get _formatted {
    final minutes = widget.remaining.inMinutes;
    final seconds = widget.remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const ink = VTColors.onGreen;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.progress),
      duration: VTRestTimer.colorGlide,
      builder: (context, progress, child) => AnimatedBuilder(
        animation: _sweep,
        builder: (context, sweptChild) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * _sweep.value, 0),
              end: Alignment(3 - 2 * _sweep.value, 0),
              colors: [
                VTRestTimer.trailingColorAt(progress),
                VTRestTimer.colorAt(progress),
                VTRestTimer.trailingColorAt(progress),
                VTRestTimer.colorAt(progress),
                VTRestTimer.trailingColorAt(progress),
              ],
            ),
            borderRadius: VTRadius.borderRadiusL,
          ),
          child: sweptChild,
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.s, VTSpacing.s, VTSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(
                    _formatted,
                    style: VTTextStyles.headline(context).copyWith(color: ink, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  Text(
                    widget.label ?? l10n.workoutRestTimerLabel,
                    style: VTTextStyles.caption(context).copyWith(color: ink.withValues(alpha: 0.85)),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(onPressed: widget.onShorten, icon: const Icon(Icons.remove), color: ink, tooltip: l10n.workoutRestShortenAction),
            IconButton(onPressed: widget.onExtend, icon: const Icon(Icons.add), color: ink, tooltip: l10n.workoutRestExtendAction),
            if (widget.onConfigure != null)
              IconButton(onPressed: widget.onConfigure, icon: const Icon(Icons.tune), color: ink, tooltip: l10n.workoutRestConfigureAction),
            const VTGap.xs(),
            TextButton(
              onPressed: widget.onSkip,
              style: TextButton.styleFrom(foregroundColor: ink),
              child: Text(l10n.workoutRestSkipAction),
            ),
          ],
        ),
      ),
    );
  }
}

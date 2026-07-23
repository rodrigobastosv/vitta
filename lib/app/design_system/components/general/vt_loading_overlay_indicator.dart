import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

// The global loading overlay's visual: a ring that cycles through the app's
// activities - diet, water, workout, sleep, reminders, body weight - each in its
// own accent, so a wait reads as Vitta rather than as a generic spinner. The
// icons and accents are restated here rather than read off HomeFeature: the
// design system never imports the domain, and this is a decorative loop that
// must not change shape when a feature is added or hidden from the home screen.
// The rotation is a continuous loop, not a transition (see the motion scan's
// _allowed). Honours reduce-motion by holding still on the first activity.
class VTLoadingOverlayIndicator extends StatefulWidget {
  const VTLoadingOverlayIndicator({super.key});

  @override
  State<VTLoadingOverlayIndicator> createState() => _VTLoadingOverlayIndicatorState();
}

class _LoadingActivity {
  const _LoadingActivity(this.icon, this.color);

  final IconData icon;
  final Color color;
}

const _activities = <_LoadingActivity>[
  _LoadingActivity(Icons.restaurant_outlined, VTColors.macroCarbs),
  _LoadingActivity(Icons.water_drop_outlined, VTColors.water),
  _LoadingActivity(Icons.fitness_center_outlined, VTColors.green),
  _LoadingActivity(Icons.bedtime_outlined, VTColors.sleep),
  _LoadingActivity(Icons.checklist_rounded, VTColors.coral),
  _LoadingActivity(Icons.monitor_weight_outlined, VTColors.success),
];

class _VTLoadingOverlayIndicatorState extends State<VTLoadingOverlayIndicator> {
  static const _step = Duration(milliseconds: 900);
  static const _size = 72.0;

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_step, (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % _activities.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final index = reduceMotion ? 0 : _index;
    final activity = _activities[index];

    return Center(
      child: SizedBox.square(
        dimension: _size,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(begin: _activities.first.color, end: activity.color),
          duration: VTMotion.transition,
          curve: VTMotion.curve,
          builder: (context, color, _) => Stack(
            alignment: .center,
            children: [
              SizedBox.expand(child: CircularProgressIndicator(strokeWidth: 3, color: color)),
              AnimatedSwitcher(
                duration: VTMotion.transition,
                switchInCurve: VTMotion.curve,
                switchOutCurve: VTMotion.curve,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: Tween<double>(begin: 0.6, end: 1).animate(animation), child: child),
                ),
                child: Icon(activity.icon, key: ValueKey(index), size: 32, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

/// Pull-to-refresh that reveals the app's own [VTLoadingOverlayIndicator] rather
/// than Material's spinner, so a pull reads as Vitta like every other wait does.
/// Material's `RefreshIndicator` draws a `RefreshProgressIndicator` and exposes
/// no hook to replace it, which is why the gesture is tracked here instead — the
/// same "own the look" call the charts, `VTCelebration` and `VTWaterFill` make.
///
/// The pull is read off scroll notifications so it works under either platform's
/// physics untouched: a bouncing scrollable reports the pull as [ScrollMetrics]
/// past `minScrollExtent`, a clamping one can't move and reports it as
/// [OverscrollNotification] instead.
class VTRefreshIndicator extends StatefulWidget {
  const VTRefreshIndicator({required this.onRefresh, required this.child, super.key});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<VTRefreshIndicator> createState() => _VTRefreshIndicatorState();
}

class _VTRefreshIndicatorState extends State<VTRefreshIndicator> with SingleTickerProviderStateMixin {
  static const _triggerExtent = 96.0;
  static const _indicatorExtent = 64.0;
  static const _indicatorSize = 40.0;
  static const _minIndicatorScale = 0.6;

  late final AnimationController _settle = AnimationController(vsync: this, duration: VTMotion.transition);

  double _pull = 0;
  bool _isArmed = false;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  double get _progress => _isRefreshing ? 1 : (_pull / _triggerExtent).clamp(0, 1);

  bool _handleNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification is UserScrollNotification && notification.direction == ScrollDirection.idle) {
      _release();
    } else if (!_isRefreshing) {
      _trackPull(notification);
    }
    return false;
  }

  void _trackPull(ScrollNotification notification) {
    if (notification is OverscrollNotification && notification.overscroll < 0) {
      _setPull(_pull - notification.overscroll);
      return;
    }
    final metrics = notification.metrics;
    if (metrics.pixels < metrics.minScrollExtent) {
      _setPull(metrics.minScrollExtent - metrics.pixels);
    } else if (notification is ScrollUpdateNotification) {
      _setPull(0);
    }
  }

  void _setPull(double pull) {
    final clamped = pull.clamp(0.0, _triggerExtent);
    if (clamped == _pull) {
      return;
    }
    final isArmed = clamped >= _triggerExtent;
    if (isArmed && !_isArmed) {
      VTHaptics.selection();
    }
    setState(() {
      _pull = clamped;
      _isArmed = isArmed;
    });
  }

  Future<void> _release() async {
    if (_isRefreshing) {
      return;
    }
    if (!_isArmed) {
      _setPull(0);
      return;
    }
    setState(() {
      _isRefreshing = true;
      _pull = 0;
      _isArmed = false;
    });
    await _settle.forward();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        await _settle.reverse();
        if (mounted) {
          setState(() => _isRefreshing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: _handleNotification,
    child: AnimatedBuilder(
      animation: _settle,
      builder: (context, child) => Stack(
        children: [
          Padding(padding: EdgeInsets.only(top: _indicatorExtent * _settle.value), child: child),
          if (_progress > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _indicatorExtent,
              child: Opacity(
                opacity: _progress,
                child: Transform.scale(
                  scale: _minIndicatorScale + (1 - _minIndicatorScale) * _progress,
                  child: const VTLoadingOverlayIndicator(size: _indicatorSize),
                ),
              ),
            ),
        ],
      ),
      child: widget.child,
    ),
  );
}

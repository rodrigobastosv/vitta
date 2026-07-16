import 'dart:async';

import 'package:flutter/material.dart';

class VTAppearEffect extends StatefulWidget {
  const VTAppearEffect({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.offset = const Offset(0, 0.08),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<VTAppearEffect> createState() => _VTAppearEffectState();
}

class _VTAppearEffectState extends State<VTAppearEffect> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSlide(
    offset: _isVisible ? Offset.zero : widget.offset,
    duration: widget.duration,
    curve: Curves.easeOutCubic,
    child: AnimatedOpacity(opacity: _isVisible ? 1 : 0, duration: widget.duration, curve: Curves.easeOutCubic, child: widget.child),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

class VTAppearEffect extends StatefulWidget {
  const VTAppearEffect({required this.child, this.index = 0, this.offset = const Offset(0, 0.08), super.key});

  final Widget child;
  final int index;
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
    _timer = Timer(VTMotion.staggerFor(widget.index), () {
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
    duration: VTMotion.entrance,
    curve: VTMotion.curve,
    child: AnimatedOpacity(opacity: _isVisible ? 1 : 0, duration: VTMotion.entrance, curve: VTMotion.curve, child: widget.child),
  );
}

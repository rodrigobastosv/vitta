import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTSkeleton extends StatefulWidget {
  const VTSkeleton({this.height = 16, this.width, this.borderRadius, super.key});

  const VTSkeleton.card({this.height = 120, this.width, super.key}) : borderRadius = VTRadius.borderRadiusM;

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<VTSkeleton> createState() => _VTSkeletonState();
}

class _VTSkeletonState extends State<VTSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: VTMotion.data)
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.35, end: 0.7).chain(CurveTween(curve: Curves.easeInOut))),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.10),
          borderRadius: widget.borderRadius ?? VTRadius.borderRadiusS,
        ),
      ),
    );
  }
}

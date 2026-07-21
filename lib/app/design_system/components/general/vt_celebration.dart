import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

enum VTCelebrationSize {
  small(particleCount: 14, spread: 90, particleSize: 5),
  large(particleCount: 34, spread: 190, particleSize: 7);

  const VTCelebrationSize({required this.particleCount, required this.spread, required this.particleSize});

  final int particleCount;
  final double spread;
  final double particleSize;
}

class VTCelebration extends StatefulWidget {
  const VTCelebration({required this.trigger, required this.child, this.size = VTCelebrationSize.large, super.key});

  static const Key burstKey = ValueKey('vt-celebration-burst');

  final bool trigger;
  final Widget child;
  final VTCelebrationSize size;

  @override
  State<VTCelebration> createState() => _VTCelebrationState();
}

class _VTCelebrationState extends State<VTCelebration> with SingleTickerProviderStateMixin {
  static const List<Color> _palette = [VTColors.success, VTColors.macroProtein, VTColors.macroCarbs, VTColors.macroFat, VTColors.macroFiber];

  late final AnimationController _controller = AnimationController(vsync: this, duration: VTMotion.celebration);
  late final List<_Particle> _particles = _buildParticles();

  @override
  void initState() {
    super.initState();
    if (widget.trigger) {
      unawaited(_celebrate());
    }
  }

  @override
  void didUpdateWidget(VTCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      unawaited(_celebrate());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _celebrate() async {
    unawaited(VTHaptics.success());
    await _controller.forward(from: 0);
    if (mounted) {
      _controller.reset();
    }
  }

  List<_Particle> _buildParticles() {
    final random = math.Random(widget.size.particleCount);
    return [
      for (var index = 0; index < widget.size.particleCount; index++)
        _Particle(
          angle: (index / widget.size.particleCount) * 2 * math.pi + random.nextDouble() * 0.4,
          distance: widget.size.spread * (0.55 + random.nextDouble() * 0.45),
          color: _palette[index % _palette.length],
          rotations: random.nextDouble() * 4 - 2,
          delay: random.nextDouble() * 0.15,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return Stack(
      alignment: .center,
      clipBehavior: .none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _controller.isDismissed
                  ? const SizedBox.shrink()
                  : CustomPaint(
                      key: VTCelebration.burstKey,
                      painter: _BurstPainter(particles: _particles, progress: _controller.value, particleSize: widget.size.particleSize),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  const _Particle({required this.angle, required this.distance, required this.color, required this.rotations, required this.delay});

  final double angle;
  final double distance;
  final Color color;
  final double rotations;
  final double delay;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.particles, required this.progress, required this.particleSize});

  final List<_Particle> particles;
  final double progress;
  final double particleSize;

  static const double _gravity = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = size.center(Offset.zero);
    for (final particle in particles) {
      final localProgress = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }
      final eased = VTMotion.curve.transform(localProgress);
      final travelled = particle.distance * eased;
      final fall = _gravity * particle.distance * localProgress * localProgress;
      final centre = origin + Offset(math.cos(particle.angle) * travelled, math.sin(particle.angle) * travelled + fall);

      canvas
        ..save()
        ..translate(centre.dx, centre.dy)
        ..rotate(particle.rotations * 2 * math.pi * localProgress);
      final paint = Paint()..color = particle.color.withValues(alpha: (1 - localProgress).clamp(0.0, 1.0));
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: particleSize, height: particleSize * 1.6), const Radius.circular(1.5)),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.progress != progress;
}

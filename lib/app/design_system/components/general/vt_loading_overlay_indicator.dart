import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

class VTLoadingOverlayIndicator extends StatefulWidget {
  const VTLoadingOverlayIndicator({super.key});

  @override
  State<VTLoadingOverlayIndicator> createState() => _VTLoadingOverlayIndicatorState();
}

class _VTLoadingOverlayIndicatorState extends State<VTLoadingOverlayIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    return Center(
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.expand(
              child: CircularProgressIndicator(strokeWidth: 3, color: VTColors.greenLight),
            ),
            ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.05).animate(pulse),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.75, end: 1).animate(pulse),
                child: const Icon(Icons.eco, size: 32, color: VTColors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

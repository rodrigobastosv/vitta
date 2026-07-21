import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class ExercisePhotoHeader extends StatefulWidget {
  const ExercisePhotoHeader({required this.imageUrls, super.key});

  final List<String> imageUrls;

  @override
  State<ExercisePhotoHeader> createState() => _ExercisePhotoHeaderState();
}

class _ExercisePhotoHeaderState extends State<ExercisePhotoHeader> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Stack(
      fit: .expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: .topLeft, end: .bottomLeft, colors: [colorScheme.primaryContainer, colorScheme.surface]),
          ),
        ),
        if (widget.imageUrls.isNotEmpty)
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => VTRemoteImage(
              imageUrl: widget.imageUrls[index],
              placeholderIcon: Icons.fitness_center_outlined,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        // The title sits over the photo and the catalog's shots are mostly bright
        // gym interiors, so it needs a scrim rather than luck.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: .bottomCenter, end: .center, colors: [Color(0xB3000000), Color(0x00000000)]),
            ),
          ),
        ),
        if (widget.imageUrls.length > 1)
          PositionedDirectional(
            bottom: VTSpacing.m,
            end: VTSpacing.m,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0x66000000), borderRadius: VTRadius.borderRadiusFull),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    for (var index = 0; index < widget.imageUrls.length; index++)
                      AnimatedContainer(
                        duration: VTMotion.transition,
                        curve: VTMotion.curve,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: index == _page ? 14 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: index == _page ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          borderRadius: VTRadius.borderRadiusFull,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

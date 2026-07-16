import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class WorkoutExerciseThumbnail extends StatelessWidget {
  const WorkoutExerciseThumbnail({required this.imageUrl, required this.isCompleted, super.key});

  final String? imageUrl;
  final bool isCompleted;

  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final image = VTRemoteImage(
      imageUrl: imageUrl,
      placeholderIcon: Icons.fitness_center_outlined,
      borderRadius: VTRadius.borderRadiusM,
      size: isCompleted ? 44 : 56,
    );
    return isCompleted ? ColorFiltered(colorFilter: _grayscale, child: image) : image;
  }
}

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class WorkoutExerciseThumbnail extends StatelessWidget {
  const WorkoutExerciseThumbnail({required this.imageUrl, required this.isCompleted, super.key});

  final String? imageUrl;
  final bool isCompleted;

  /// Luminance weights - the same ones a contrast ratio is built from, so the
  /// grey a photo collapses to matches how bright it actually read in colour.
  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final image = VTRemoteImage(
      imageUrl: imageUrl,
      placeholderIcon: Icons.fitness_center_outlined,
      borderRadius: VTRadius.borderRadiusM,
      // Smaller once done: the card is still there to be recognised, not to be
      // worked from.
      size: isCompleted ? 44 : 56,
    );
    // Done drains the photo of colour rather than stamping an icon over it:
    // the picture is what identifies the exercise, so it should recede, not be
    // covered. Nothing here touches the text.
    return isCompleted ? ColorFiltered(colorFilter: _grayscale, child: image) : image;
  }
}

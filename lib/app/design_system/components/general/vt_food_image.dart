import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTFoodImage extends StatelessWidget {
  const VTFoodImage({required this.imageUrl, this.size = 48, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final url = imageUrl;
    return ClipRRect(
      borderRadius: VTRadius.borderRadiusS,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? _Placeholder(colorScheme: colorScheme, size: size)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _Placeholder(colorScheme: colorScheme, size: size),
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null ? child : _Placeholder(colorScheme: colorScheme, size: size),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colorScheme, required this.size});

  final ColorScheme colorScheme;
  final double size;

  // A faint primary tint rather than surfaceContainerHighest, which is close
  // enough to VTCard's own fill that the box disappears and the icon reads as
  // floating loose on the card. Low-contrast on purpose: a missing photo should
  // recede, not draw the eye away from the food's name.
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: colorScheme.primary.withValues(alpha: 0.08),
    child: Icon(Icons.restaurant_outlined, color: colorScheme.primary.withValues(alpha: 0.45), size: size * 0.42),
  );
}

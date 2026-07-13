import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTFoodImage extends StatelessWidget {
  const VTFoodImage({required this.imageUrl, this.size = 48, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: colorScheme.surfaceContainerHighest,
    child: Icon(Icons.restaurant_outlined, color: colorScheme.onSurfaceVariant, size: size * 0.5),
  );
}

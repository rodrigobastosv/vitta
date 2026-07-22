import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';

class VTFoodImage extends StatelessWidget {
  const VTFoodImage({required this.imageUrl, this.placeholderIcon = Icons.restaurant_outlined, this.placeholderTint, this.size = 48, super.key});

  final String? imageUrl;
  final IconData placeholderIcon;
  final Color? placeholderTint;
  final double size;

  @override
  Widget build(BuildContext context) => VTRemoteImage(imageUrl: imageUrl, placeholderIcon: placeholderIcon, placeholderTint: placeholderTint, size: size);
}

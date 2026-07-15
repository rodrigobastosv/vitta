import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';

class VTFoodImage extends StatelessWidget {
  const VTFoodImage({required this.imageUrl, this.size = 48, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) => VTRemoteImage(imageUrl: imageUrl, placeholderIcon: Icons.restaurant_outlined, size: size);
}

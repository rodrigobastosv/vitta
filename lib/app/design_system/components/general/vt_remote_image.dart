import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image_placeholder.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTRemoteImage extends StatelessWidget {
  const VTRemoteImage({required this.imageUrl, required this.placeholderIcon, this.size = 48, this.width, this.height, this.borderRadius, super.key});

  final String? imageUrl;
  final IconData placeholderIcon;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final url = imageUrl;
    final resolvedWidth = width ?? size;
    final resolvedHeight = height ?? size;
    final placeholder = VTRemoteImagePlaceholder(
      colorScheme: colorScheme,
      icon: placeholderIcon,
      iconSize: (resolvedWidth < resolvedHeight ? resolvedWidth : resolvedHeight) * 0.42,
    );
    return ClipRRect(
      borderRadius: borderRadius ?? VTRadius.borderRadiusS,
      child: SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: url == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => placeholder,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

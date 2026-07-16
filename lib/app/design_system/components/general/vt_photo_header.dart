import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTPhotoHeader extends StatelessWidget {
  const VTPhotoHeader({required this.imageBytes, required this.onTap, this.imageUrl, super.key});

  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final photo = _photo();
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: .expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: .topLeft, end: .bottomLeft, colors: [colorScheme.primaryContainer, colorScheme.surface]),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            child: photo ?? _placeholder(context),
          ),
          if (photo != null) Positioned(right: VTSpacing.m, bottom: VTSpacing.m, child: _changePhotoChip(context)),
        ],
      ),
    );
  }

  Widget? _photo() {
    final bytes = imageBytes;
    if (bytes != null) {
      return Image.memory(bytes, key: ValueKey(bytes.length), fit: BoxFit.cover, width: double.infinity);
    }
    final url = imageUrl;
    if (url == null) {
      return null;
    }
    return Image.network(
      url,
      key: ValueKey(url),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.16), shape: .circle),
            child: Icon(Icons.add_a_photo_outlined, color: colorScheme.primary, size: 32),
          ),
          const VTGap.s(),
          Text(context.l10n.addPhotoAction, style: VTTextStyles.caption(context)),
        ],
      ),
    );
  }

  Widget _changePhotoChip(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s + VTSpacing.xs, vertical: VTSpacing.xs + 2),
      decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.9), borderRadius: VTRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(Icons.photo_camera_outlined, size: 16, color: colorScheme.primary),
          const VTGap.xs(),
          Text(context.l10n.changePhotoAction, style: VTTextStyles.overline(context).copyWith(color: colorScheme.primary)),
        ],
      ),
    );
  }
}

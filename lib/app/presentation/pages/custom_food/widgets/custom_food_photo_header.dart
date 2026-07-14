import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class CustomFoodPhotoHeader extends StatelessWidget {
  const CustomFoodPhotoHeader({required this.imageBytes, required this.onTap, super.key});

  final Uint8List? imageBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final bytes = imageBytes;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: .expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: .topLeft,
                end: .bottomLeft,
                colors: [colorScheme.primaryContainer, colorScheme.surface],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            child: bytes == null
                ? _placeholder(context)
                : Image.memory(bytes, key: ValueKey(bytes.length), fit: BoxFit.cover, width: double.infinity),
          ),
          if (bytes != null)
            Positioned(
              right: VTSpacing.m,
              bottom: VTSpacing.m,
              child: _changePhotoChip(context),
            ),
        ],
      ),
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
          Text(context.l10n.dietAddPhotoAction, style: VTTextStyles.caption(context)),
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
          Text(context.l10n.dietChangePhotoAction, style: VTTextStyles.overline(context).copyWith(color: colorScheme.primary)),
        ],
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_avatar_catalog.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// A circular profile avatar resolving, in order: an uploaded photo, a chosen
/// preset avatar (see [VTAvatarCatalog]), a name/email initial, then a fallback
/// person icon (issue #117). The precedence lives here so every place that
/// shows the avatar - the home app-bar, the profile header, the sign-up/edit
/// preview - agrees.
///
/// [previewBytes] is the one exception: while a photo is being picked it hasn't
/// been uploaded yet, so there's no URL, and the raw bytes are shown instead.
/// It wins over everything, since it's the choice the user is actively making.
class VTProfileAvatar extends StatelessWidget {
  const VTProfileAvatar({
    this.avatarUrl,
    this.avatarId,
    this.initial,
    this.previewBytes,
    this.size = 32,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String? avatarUrl;
  final String? avatarId;
  final String? initial;
  final Uint8List? previewBytes;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final background = backgroundColor ?? colorScheme.primaryContainer;
    final foreground = foregroundColor ?? colorScheme.onPrimaryContainer;

    final bytes = previewBytes;
    if (bytes != null) {
      return ClipOval(child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover));
    }
    if (avatarUrl != null) {
      return VTRemoteImage(
        imageUrl: avatarUrl,
        placeholderIcon: Icons.person_outline,
        size: size,
        borderRadius: BorderRadius.circular(size / 2),
      );
    }
    if (VTAvatarCatalog.byId(avatarId) case final option?) {
      return VTAvatarCatalog.buildAvatar(option, size: size);
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: background,
      child: switch (initial) {
        final initial? => Text(
          initial,
          style: VTTextStyles.body(context).copyWith(color: foreground, fontWeight: FontWeight.bold, fontSize: size * 0.44),
        ),
        _ => Icon(Icons.person_outline, size: size * 0.56, color: foreground),
      },
    );
  }
}

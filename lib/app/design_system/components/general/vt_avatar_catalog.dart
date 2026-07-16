import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

/// One choosable preset avatar (issue #117): a face on a soft two-colour
/// gradient, identified by a stable [id] that's what gets stored on the
/// profile. The faces are the person emoji with skin-tone, gender and hair
/// modifiers, so the gallery spans a diverse set (man/woman, light/dark, blond,
/// red, curly, bearded, older) without shipping image assets or a dependency -
/// the same "own the small component" call the charts make. A new option is one
/// entry here.
class VTAvatarOption {
  const VTAvatarOption({required this.id, required this.emoji, required this.colors});

  final String id;
  final String emoji;
  final List<Color> colors;
}

abstract class VTAvatarCatalog {
  // Soft pastel pairs so a face reads clearly on top, cycled across the faces.
  static const List<Color> _mint = [VTColors.greenContainerLight, VTColors.greenLight];
  static const List<Color> _peach = [VTColors.coralContainerLight, VTColors.coralLight];
  static const List<Color> _butter = [VTColors.warningContainerLight, VTColors.warning];
  static const List<Color> _rose = [VTColors.errorContainerLight, VTColors.coral];

  /// The gallery, in display order. Ids are stable strings, never the list
  /// index - reordering or inserting must not change what an existing profile
  /// resolves to.
  static const List<VTAvatarOption> options = [
    VTAvatarOption(id: 'man-light', emoji: '👨🏻', colors: _mint),
    VTAvatarOption(id: 'woman-light', emoji: '👩🏻', colors: _peach),
    VTAvatarOption(id: 'man-blond', emoji: '👱🏼‍♂️', colors: _butter),
    VTAvatarOption(id: 'woman-blond', emoji: '👱🏻‍♀️', colors: _rose),
    VTAvatarOption(id: 'woman-blond-medium', emoji: '👱🏽‍♀️', colors: _mint),
    VTAvatarOption(id: 'man-medium', emoji: '👨🏽', colors: _peach),
    VTAvatarOption(id: 'woman-medium', emoji: '👩🏽', colors: _butter),
    VTAvatarOption(id: 'man-medium-dark', emoji: '👨🏾', colors: _rose),
    VTAvatarOption(id: 'woman-medium-dark', emoji: '👩🏾', colors: _mint),
    VTAvatarOption(id: 'man-red', emoji: '👨🏼‍🦰', colors: _peach),
    VTAvatarOption(id: 'woman-red', emoji: '👩🏼‍🦰', colors: _butter),
    VTAvatarOption(id: 'man-red-dark', emoji: '👨🏿‍🦰', colors: _rose),
    VTAvatarOption(id: 'woman-red-dark', emoji: '👩🏿‍🦰', colors: _mint),
    VTAvatarOption(id: 'man-dark', emoji: '👨🏿', colors: _peach),
    VTAvatarOption(id: 'woman-dark', emoji: '👩🏿', colors: _butter),
    VTAvatarOption(id: 'man-curly', emoji: '👨🏾‍🦱', colors: _rose),
    VTAvatarOption(id: 'woman-curly', emoji: '👩🏾‍🦱', colors: _mint),
    VTAvatarOption(id: 'man-curly-light', emoji: '👨🏻‍🦱', colors: _peach),
    VTAvatarOption(id: 'woman-curly-dark', emoji: '👩🏿‍🦱', colors: _butter),
    VTAvatarOption(id: 'man-white-hair', emoji: '👨🏻‍🦳', colors: _rose),
    VTAvatarOption(id: 'woman-white-hair', emoji: '👩🏽‍🦳', colors: _mint),
    VTAvatarOption(id: 'man-bald', emoji: '👨🏼‍🦲', colors: _peach),
    VTAvatarOption(id: 'man-bald-dark', emoji: '👨🏿‍🦲', colors: _butter),
    VTAvatarOption(id: 'man-beard', emoji: '🧔🏻', colors: _rose),
    VTAvatarOption(id: 'man-beard-medium', emoji: '🧔🏽', colors: _mint),
    VTAvatarOption(id: 'man-beard-dark', emoji: '🧔🏿', colors: _peach),
    VTAvatarOption(id: 'person-light', emoji: '🧑🏻', colors: _butter),
    VTAvatarOption(id: 'person-medium', emoji: '🧑🏽', colors: _rose),
    VTAvatarOption(id: 'person-dark', emoji: '🧑🏿', colors: _mint),
    VTAvatarOption(id: 'older-man', emoji: '👴🏼', colors: _peach),
    VTAvatarOption(id: 'older-man-dark', emoji: '👴🏿', colors: _butter),
    VTAvatarOption(id: 'older-woman', emoji: '👵🏽', colors: _rose),
    VTAvatarOption(id: 'older-woman-light', emoji: '👵🏻', colors: _mint),
  ];

  static VTAvatarOption? byId(String? id) {
    if (id == null) {
      return null;
    }
    for (final option in options) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  /// Renders an option as a circular gradient avatar. Shared by the picker grid
  /// and [VTProfileAvatar] so an option looks the same everywhere.
  static Widget buildAvatar(VTAvatarOption option, {required double size}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: option.colors),
    ),
    child: Text(option.emoji, style: TextStyle(fontSize: size * 0.56)),
  );
}

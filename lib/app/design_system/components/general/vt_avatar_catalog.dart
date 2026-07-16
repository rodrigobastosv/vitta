import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

/// One choosable preset avatar (issue #117): a glyph on a two-colour gradient,
/// identified by a stable [id] that's what gets stored on the profile. Owned
/// and rendered by us rather than shipped as image assets or a dependency -
/// the same "own the small component" call the charts and emoji-free approach
/// make - so a new option is one entry here, no asset pipeline.
class VTAvatarOption {
  const VTAvatarOption({required this.id, required this.icon, required this.colors});

  final String id;
  final IconData icon;
  final List<Color> colors;
}

abstract class VTAvatarCatalog {
  static const Color _ink = VTColors.onGreen;

  /// The gallery, in display order. Ids are stable strings, never the list
  /// index - reordering or inserting must not change what an existing profile
  /// resolves to.
  static const List<VTAvatarOption> options = [
    VTAvatarOption(id: 'leaf', icon: Icons.eco, colors: [VTColors.green, VTColors.greenLight]),
    VTAvatarOption(id: 'flame', icon: Icons.local_fire_department, colors: [VTColors.coral, VTColors.coralLight]),
    VTAvatarOption(id: 'bolt', icon: Icons.bolt, colors: [VTColors.macroCarbs, VTColors.coralLight]),
    VTAvatarOption(id: 'wave', icon: Icons.waves, colors: [VTColors.macroFat, VTColors.greenLight]),
    VTAvatarOption(id: 'spa', icon: Icons.spa, colors: [VTColors.macroFiber, VTColors.greenLight]),
    VTAvatarOption(id: 'star', icon: Icons.star, colors: [VTColors.warning, VTColors.macroCarbs]),
    VTAvatarOption(id: 'heart', icon: Icons.favorite, colors: [VTColors.error, VTColors.coral]),
    VTAvatarOption(id: 'rocket', icon: Icons.rocket_launch, colors: [VTColors.bodyRegionCore, VTColors.macroFat]),
    VTAvatarOption(id: 'paw', icon: Icons.pets, colors: [VTColors.coral, VTColors.macroCarbs]),
    VTAvatarOption(id: 'bird', icon: Icons.flutter_dash, colors: [VTColors.macroFat, VTColors.macroFiber]),
    VTAvatarOption(id: 'ball', icon: Icons.sports_soccer, colors: [VTColors.green, VTColors.macroFat]),
    VTAvatarOption(id: 'bike', icon: Icons.pedal_bike, colors: [VTColors.macroFiber, VTColors.macroFat]),
    VTAvatarOption(id: 'yoga', icon: Icons.self_improvement, colors: [VTColors.bodyRegionCore, VTColors.coralLight]),
    VTAvatarOption(id: 'music', icon: Icons.music_note, colors: [VTColors.coral, VTColors.bodyRegionCore]),
    VTAvatarOption(id: 'brush', icon: Icons.brush, colors: [VTColors.macroCarbs, VTColors.macroFiber]),
    VTAvatarOption(id: 'sun', icon: Icons.wb_sunny, colors: [VTColors.warning, VTColors.coral]),
    VTAvatarOption(id: 'snow', icon: Icons.ac_unit, colors: [VTColors.macroFat, VTColors.greenLight]),
    VTAvatarOption(id: 'game', icon: Icons.sports_esports, colors: [VTColors.bodyRegionCore, VTColors.green]),
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
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: option.colors),
    ),
    child: Icon(option.icon, size: size * 0.5, color: _ink),
  );
}

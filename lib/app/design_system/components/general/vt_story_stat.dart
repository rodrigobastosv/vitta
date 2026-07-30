import 'package:flutter/widgets.dart';

/// One figure on a [VTStoryCard] — the accent carries the icon, so the icon is
/// inked with `VTColors.inkOn` rather than the accent itself.
///
/// The change reads as an arrow plus a signed figure and is deliberately handed
/// over as a plain glyph and string: a direction has no good/bad valence to
/// colour by, and what counts as up is the caller's domain, not the card's.
class VTStoryStat {
  const VTStoryStat({required this.icon, required this.accent, required this.label, required this.value, this.changeIcon, this.changeLabel});

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final IconData? changeIcon;
  final String? changeLabel;
}

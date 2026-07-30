import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutBodyMapFigure extends StatelessWidget {
  const WorkoutBodyMapFigure({
    required this.view,
    required this.caption,
    required this.highlights,
    this.figureHeight = 168,
    super.key,
  });

  final VTBodyMapView view;

  // Null where the figure has no room to be captioned; front-versus-back reads
  // from the drawing, and the card names the muscles to VoiceOver regardless.
  final String? caption;
  final List<VTBodyMapHighlight> highlights;
  final double figureHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        VTBodyMap(view: view, highlights: highlights, height: figureHeight),
        if (caption case final caption?) ...[
          const VTGap.s(),
          Text(caption, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant), textAlign: .center),
        ],
      ],
    );
  }
}

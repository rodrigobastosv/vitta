import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_highlight.dart';
import 'package:vitta/app/design_system/components/general/vt_body_map_view.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutBodyMapFigure extends StatelessWidget {
  const WorkoutBodyMapFigure({required this.view, required this.caption, required this.highlights, super.key});

  final VTBodyMapView view;
  final String caption;
  final List<VTBodyMapHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        VTBodyMap(view: view, highlights: highlights),
        const VTGap.s(),
        Text(caption, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant), textAlign: .center),
      ],
    );
  }
}

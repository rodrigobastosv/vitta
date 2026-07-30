import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_story_stat.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// A 9:16 card built to leave the app as an image — the shape every story
/// surface expects, branded with the leaf mark and the app's palette.
///
/// Its size is fixed rather than adaptive: what gets exported must be the same
/// number of pixels on every device, so a caller scales it to the screen with a
/// `FittedBox` instead of letting the screen decide the export. Everything with
/// a figure on it sits on a [VTCard] rather than directly on the gradient, so
/// captions keep the contrast they were measured at on a plain card surface.
class VTStoryCard extends StatelessWidget {
  const VTStoryCard({required this.brandName, required this.eyebrow, required this.headline, required this.stats, required this.footnote, super.key});

  final String brandName;
  final String eyebrow;
  final Widget headline;
  final List<VTStoryStat> stats;
  final String footnote;

  static const double width = 360;
  static const double height = 640;

  static const double _markSize = 44;
  static const double _statIconSize = 30;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(VTSpacing.l),
      decoration: BoxDecoration(
        borderRadius: VTRadius.borderRadiusL,
        gradient: LinearGradient(begin: .topLeft, end: .bottomRight, colors: [colorScheme.primaryContainer, colorScheme.surface]),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _brand(context),
          const VTGap.l(),
          Expanded(
            child: VTCard(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  headline,
                  const VTGap.m(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .spaceEvenly,
                      children: [for (final stat in stats) _stat(context, stat)],
                    ),
                  ),
                  Text(footnote, style: VTTextStyles.overline(context), textAlign: .center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Container(
          width: _markSize,
          height: _markSize,
          decoration: BoxDecoration(color: colorScheme.primary, shape: .circle),
          child: Icon(Icons.eco_outlined, size: 24, color: VTColors.inkOn(colorScheme.primary)),
        ),
        const VTGap.s(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(brandName, style: VTTextStyles.title(context), maxLines: 1, overflow: .ellipsis),
              Text(eyebrow, style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurface), maxLines: 1, overflow: .ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, VTStoryStat stat) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Container(
          width: _statIconSize,
          height: _statIconSize,
          decoration: BoxDecoration(color: stat.accent, shape: .circle),
          child: Icon(stat.icon, size: 16, color: VTColors.inkOn(stat.accent)),
        ),
        const VTGap.s(),
        Expanded(child: Text(stat.label, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis)),
        const VTGap.s(),
        Column(
          crossAxisAlignment: .end,
          mainAxisSize: .min,
          children: [
            Text(stat.value, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
            if (stat.changeLabel case final changeLabel?)
              Row(
                mainAxisSize: .min,
                children: [
                  Icon(stat.changeIcon, size: 12, color: colorScheme.onSurfaceVariant),
                  const VTGap.xs(),
                  Text(changeLabel, style: VTTextStyles.overline(context), maxLines: 1),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

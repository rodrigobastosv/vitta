import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';

class TrendsSkeleton extends StatelessWidget {
  const TrendsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: .start,
    children: [
      VTSkeleton(height: 36),
      VTGap.m(),
      VTSkeleton.card(height: 190),
      VTGap.l(),
      VTSkeleton(width: 96),
      VTGap.m(),
      VTSkeleton.card(height: 230),
      VTGap.m(),
      VTSkeleton.card(height: 230),
    ],
  );
}

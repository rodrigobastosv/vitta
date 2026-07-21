import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';

class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: .start,
    children: [
      VTSkeleton.card(height: 280),
      VTGap.l(),
      VTSkeleton(width: 96),
      VTGap.m(),
      VTSkeleton(height: 36),
      VTGap.m(),
      VTSkeleton.card(height: 200),
      VTGap.m(),
      VTSkeleton.card(height: 200),
    ],
  );
}

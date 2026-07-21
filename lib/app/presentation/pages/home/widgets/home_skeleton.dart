import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: .start,
    children: [
      VTSkeleton.card(height: 188),
      VTGap.l(),
      VTSkeleton(width: 76, height: 11),
      VTGap.s(),
      VTSkeleton.card(height: 168),
      VTGap.l(),
      VTSkeleton(width: 52, height: 11),
      VTGap.s(),
      Row(
        children: [
          Expanded(child: VTSkeleton.card(height: 148)),
          VTGap.m(),
          Expanded(child: VTSkeleton.card(height: 148)),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({this.headerHeight, this.rows = 4, super.key});

  final double? headerHeight;
  final int rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      if (headerHeight case final headerHeight?) ...[VTSkeleton.card(height: headerHeight), const VTGap.l()],
      for (var row = 0; row < rows; row++) ...[const VTSkeleton.card(height: 72), if (row < rows - 1) const VTGap.s()],
    ],
  );
}

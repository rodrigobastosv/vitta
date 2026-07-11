import 'package:flutter/widgets.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTGap extends SizedBox {
  const VTGap.xs({super.key}) : super.square(dimension: VTSpacing.xs);

  const VTGap.s({super.key}) : super.square(dimension: VTSpacing.s);

  const VTGap.m({super.key}) : super.square(dimension: VTSpacing.m);

  const VTGap.l({super.key}) : super.square(dimension: VTSpacing.l);

  const VTGap.xl({super.key}) : super.square(dimension: VTSpacing.xl);

  const VTGap.xxl({super.key}) : super.square(dimension: VTSpacing.xxl);
}

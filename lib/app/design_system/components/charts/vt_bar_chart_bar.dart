import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';

class VTBarChartBar {
  const VTBarChartBar({required this.segments});

  const VTBarChartBar.empty() : segments = const [];

  final List<VTBarChartSegment> segments;

  double get total => segments.fold(0, (sum, segment) => sum + segment.value);
}

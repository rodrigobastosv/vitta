import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';

class VTBarChartBar {
  const VTBarChartBar({required this.segments, this.tooltip});

  const VTBarChartBar.empty() : segments = const [], tooltip = null;

  final List<VTBarChartSegment> segments;

  // Value caption shown when the bar is tapped; null means the bar isn't tappable.
  // The caller builds the localized string so formatting stays out of the chart.
  final String? tooltip;

  double get total => segments.fold(0, (sum, segment) => sum + segment.value);
}

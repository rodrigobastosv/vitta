class VTLineChartPoint {
  const VTLineChartPoint({required this.value, this.label, this.tooltip});

  final double value;

  // Optional x-axis caption; only the first and last non-null labels are drawn, so
  // a sparse series doesn't crowd the axis.
  final String? label;

  // Value caption shown when the point is tapped; null means the point isn't tappable.
  // The caller builds the localized string so formatting stays out of the chart.
  final String? tooltip;
}

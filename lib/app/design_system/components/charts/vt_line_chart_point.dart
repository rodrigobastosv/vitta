class VTLineChartPoint {
  const VTLineChartPoint({required this.value, this.label});

  final double value;

  // Optional x-axis caption; only the first and last non-null labels are drawn, so
  // a sparse series doesn't crowd the axis.
  final String? label;
}

abstract class QuantityFormat {
  /// A quantity as it should read in a text field or a label: at most one
  /// decimal, and no trailing `.0` on a whole number - `100`, not `100.0`.
  static String format(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }
}

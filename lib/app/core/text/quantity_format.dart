abstract class QuantityFormat {
  static String format(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }
}

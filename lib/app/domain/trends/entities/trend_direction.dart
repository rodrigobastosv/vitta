enum TrendDirection {
  up,
  down,
  flat;

  static const changeTolerance = 0.03;

  static TrendDirection forChangeRatio(double changeRatio) {
    if (changeRatio > 1 + changeTolerance) {
      return .up;
    }
    if (changeRatio < 1 - changeTolerance) {
      return .down;
    }
    return .flat;
  }
}

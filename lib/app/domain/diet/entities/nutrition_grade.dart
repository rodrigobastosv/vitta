enum NutritionGrade {
  poor,
  fair,
  good,
  excellent;

  static const _fairFloor = 50;
  static const _goodFloor = 70;
  static const _excellentFloor = 85;

  static NutritionGrade forPoints(int points) {
    if (points >= _excellentFloor) {
      return .excellent;
    }
    if (points >= _goodFloor) {
      return .good;
    }
    return points >= _fairFloor ? .fair : .poor;
  }
}

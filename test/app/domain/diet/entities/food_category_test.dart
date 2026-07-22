import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_category.dart';

void main() {
  test('every case round-trips through its wire value', () {
    for (final category in FoodCategory.values) {
      expect(FoodCategory.fromWireValue(category.wireValue), category);
    }
  });

  test('the snake_case wire values stay stable', () {
    expect(FoodCategory.dairyEgg.wireValue, 'dairy_egg');
    expect(FoodCategory.legumeNut.wireValue, 'legume_nut');
    expect(FoodCategory.fatOil.wireValue, 'fat_oil');
  });

  test('fromWireValue tolerates null and unknown values as no category', () {
    expect(FoodCategory.fromWireValue(null), isNull);
    expect(FoodCategory.fromWireValue('restaurant_foods'), isNull);
  });
}

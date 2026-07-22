import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_category.dart';
import 'package:vitta/app/presentation/general/food_image.dart';

import '../../../factories/entities/food_factory.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required FoodCategory? category, String? imageUrl}) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FoodImage(food: FoodFactory.build(category: category, imageUrl: imageUrl)),
      ),
    ),
  );

  testWidgets('an imageless food shows its category icon instead of the generic placeholder', (tester) async {
    await pump(tester, category: .dairyEgg);

    expect(find.byIcon(Icons.egg_outlined), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsNothing);
  });

  testWidgets('a food with no category keeps the default placeholder', (tester) async {
    await pump(tester, category: null);

    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });
}
